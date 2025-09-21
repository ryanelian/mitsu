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
  # based on the Stale-While-Revalidate (SWR) pattern:
  # - https://datatracker.ietf.org/doc/html/rfc5861
  # - Request path (`get_rate`) returns fast from cache when present.
  # - On cache miss, we take a short-lived distributed lock, fetch from the API,
  #   store the result for 5 minutes (300s), and return the API response immediately.
  #   This balances performance and stability (no stampedes, callers do not wait for the worker).
  # - Separately, a background worker runs every 2 minutes to proactively refresh any keys
  #   that have previously been requested and cached. If there are no cached keys, it does nothing.
  #
  # Cache freshness and API quota:
  # - TTL is 5 minutes. The worker runs each 2 minutes, so stale values are refreshed
  #   well before they expire in normal operation.
  # - Upstream rate API has a daily limit of 1000 calls. With a 2-minute interval:
  #   24 hours × 60 minutes = 1440 minutes; 1440 / 2 = 720 refresh cycles/day.
  #   Even at one batch request per cycle, this remains under the 1000 calls/day limit!
  #
  # Trade-offs:
  # - The refresh uses a batch endpoint that accepts an array of parameter combinations.
  #   That payload can grow, but we know the combinatorics are bounded for this API:
  #   4 periods × 3 hotels × 3 rooms = 36 max combinations.
  # - Therefore, in a single day, the total number of API calls is bounded by 720 + 36 = 756.
  #
  # Behavior with no cached keys:
  # - If the set of cached keys is empty, there is nothing to refresh and the worker exits quickly.
  #
  # @return [Hash] Summary of refresh operation: { updated: count, errors: count }
  def self.refresh_all_cached_rates
    repo = RedisRepository.instance
    cached_keys = get_cached_rate_keys

    if cached_keys.empty?
      # No keys have been cached yet (e.g., system just started or no traffic).
      # In SWR, doing nothing here is correct: we only refresh items that have
      # been requested at least once. New items are filled by request-path misses.
      Rails.logger.info "No cached rate keys found to refresh"
      return { updated: 0, errors: 0 }
    end

    Rails.logger.info "Refreshing #{cached_keys.length} cached rate keys"

    # Parse all cached keys back to request objects for batch submission.
    # Note: keys are JSON with a fixed field order (period -> hotel -> room).
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

    # Fetch all rates in one batch request.
    # Trade-off: payload includes all known combinations, but the domain is bounded (max 36).
    rate_client = RateApiClient.new
    rates_dict = rate_client.fetch_rates(requests)

    if rates_dict.empty?
      Rails.logger.warn "Failed to fetch rates for refresh operation"
      return { updated: 0, errors: requests.length }
    end

    # We successfully fetched the rates as a single API call.
    increment_api_call_count()
    # Update cache for each successfully fetched rate (5-minute TTL / 300s).
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

          # Update cache with new rate; TTL 300s keeps data fresh while allowing headroom
          # for the 2-minute worker refresh cadence.
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
