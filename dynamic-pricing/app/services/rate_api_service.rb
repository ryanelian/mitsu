# frozen_string_literal: true

require 'json'

# Service for handling rate API calls with cache stampede prevention
class RateApiService
  # Fetch rate with cache stampede prevention
  #
  # @param period [String] The period (Summer, Autumn, Winter, Spring)
  # @param hotel [String] The hotel name
  # @param room [String] The room type
  # @return [String] The rate value as a string
  def self.get_rate(period:, hotel:, room:)
    key = get_hotel_room_query_key(period: period, hotel: hotel, room: room)

    repo = RedisRepository.instance

    # First, try to get the cached value without locking
    if (cached = repo.get(key))
      return JSON.parse(cached)
    end

    if !has_quota_remaining?
      Rails.logger.warn "No quota remaining when attempting to fetch rate for #{key}"
      raise ServiceUnavailableError.new("Service temporarily unavailable. No quota remaining.")
    end

    # Cache miss: use distributed lock to prevent stampede
    # Use the cache key as the lock resource to ensure per-key locking
    lock_resource = repo.get_lock_key(key)
    # Set lock TTL to 30 seconds (should be enough for API call + processing)
    # This prevents deadlocks if the process crashes during cache regeneration

    result = repo.with_lock(lock_resource, ttl_milliseconds: 30_000, retry_count: 2) do
      # Double-checked locking: check cache again inside the lock
      # in case another process already regenerated it while we waited
      if (cached = repo.get(key))
        JSON.parse(cached)
      else
        # We have acquired the lock and the cache is missing.
        Rails.logger.info "Cache miss for key #{key}"

        rate_client = RateApiClient.new
        rate_value = rate_client.fetch_rate(period: period, hotel: hotel, room: room)
        
        # Track actual API calls (not cache hits), only if the rate is successfully fetched
        # Ruby treats nil as false, but 0 as true unlike JavaScript.
        if (rate_value)
            increment_api_call_count()
        end

        # Cache for 5 minutes
        repo.set(key, 300, rate_value.to_json)

        # Add the key to the set of cached rate keys for background auto-refresh
        repo.add_to_set("rate_cache_keys", key)

        rate_value
      end
    end

    # Check if we successfully acquired the lock and got a result
    if result
      result
    else
      # Failed to acquire lock. This should not happen often.
      # Return a 503 Service Unavailable to indicate temporary unavailability
      Rails.logger.warn "Service temporarily unavailable. Failed to fetch rate for #{key}"
      raise ServiceUnavailableError.new("Service temporarily unavailable. Please retry.")
    end
  end

  # Get the current count of all API calls (cache hits and misses)
  def self.get_hit_count
    RedisRepository.instance.get_counter("hit_count")
  end

  # Increment the count of all API calls (cache hits and misses)
  def self.increment_hit_count
    RedisRepository.instance.increment("hit_count")
  end

  # Get the set of all cached rate keys
  def self.get_cached_rate_keys
    RedisRepository.instance.get_set_members("rate_cache_keys")
  end

  # Refresh all cached rate keys by fetching them in batch and updating cache
  # This method uses the RateApiClient's batch processing capability for efficiency
  # @return [Hash] Summary of refresh operation: { updated: count, errors: count }
  def self.refresh_all_cached_rates
    repo = RedisRepository.instance
    cached_keys = get_cached_rate_keys

    if cached_keys.empty?
      Rails.logger.info "No cached rate keys found to refresh"
      return { updated: 0, errors: 0 }
    end

    Rails.logger.info "Refreshing #{cached_keys.length} cached rate keys"

    # Parse all cached keys back to request objects
    requests = []
    cached_keys.each do |key|
      begin
        parsed_key = JSON.parse(key)
        requests << {
          period: parsed_key['period'],
          hotel: parsed_key['hotel'],
          room: parsed_key['room']
        }
      rescue JSON::ParserError => e
        Rails.logger.warn "Failed to parse cached key: #{key}, error: #{e.message}"
      end
    end

    return { updated: 0, errors: requests.length } if requests.empty?

    # Fetch all rates in batch using the API client's batch processing
    rate_client = RateApiClient.new
    rates_dict = rate_client.fetch_rates(requests)

    if rates_dict.empty?
      Rails.logger.warn "Failed to fetch rates for refresh operation"
      return { updated: 0, errors: requests.length }
    end

    # We successfully fetched the rates
    increment_api_call_count()
    # Update cache for each successfully fetched rate
    updated_count = 0
    error_count = 0

    cached_keys.each do |key|
      begin
        parsed_key = JSON.parse(key)
        period = parsed_key['period']
        hotel = parsed_key['hotel']
        room = parsed_key['room']

        # Extract rate from nested dictionary
        if rates_dict.key?(period) &&
           rates_dict[period].key?(hotel) &&
           rates_dict[period][hotel].key?(room)
          rate_value = rates_dict[period][hotel][room]

          # Update cache with new rate
          repo.set(key, 300, rate_value.to_json)
          updated_count += 1
        else
          Rails.logger.warn "Rate not found in response for #{period}/#{hotel}/#{room}"
          error_count += 1
        end
      rescue JSON::ParserError => e
        Rails.logger.warn "Failed to parse cached key during update: #{key}, error: #{e.message}"
        error_count += 1
      end
    end

    Rails.logger.info "Rate refresh completed: #{updated_count} updated, #{error_count} errors"
    { updated: updated_count, errors: error_count }
  end

  private

  # Get the key for the query for hotel room rate. Used to store the query in Redis.
  # The JSON fields order is fixed, so the key is always the same for the same query.
  # i.e. period --> hotel --> room
  def self.get_hotel_room_query_key(period:, hotel:, room:)
    { period: period, hotel: hotel, room: room }.to_json
  end

  # Increment the count of actual API calls made (not cache hits)
  def self.increment_api_call_count
    RedisRepository.instance.increment("rate_api:calls")
  end

  # Get the current count of actual API calls made (not cache hits)
  def self.get_api_call_count
    RedisRepository.instance.get_counter("rate_api:calls")
  end

  # Get the remaining quota for calling the API
  # Returns how many more API calls can be made before hitting the limit
  def self.remaining_quota
    AppSettings.rate_api_quota - get_api_call_count
  end

  # Check if quota is remaining (positive)
  def self.has_quota_remaining?
    remaining_quota > 0
  end

  # Custom error for service unavailable situations
  class ServiceUnavailableError < StandardError
    attr_reader :message

    def initialize(message)
      @message = message
      super(message)
    end
  end
end
