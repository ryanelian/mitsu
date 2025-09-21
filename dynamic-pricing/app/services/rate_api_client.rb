# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# Lightweight client for the external Rate API
# Supports both single and batch requests. The API accepts arrays of request objects
# for efficient batch processing of multiple rate queries.
#
# All methods will never raise exceptions.
# They will always return safe defaults (nil or empty hash) with proper logging.
#
# API Response Format Expected:
# {
#   "rates": [
#     {
#       "period": "Summer",
#       "hotel": "FloatingPointResort",
#       "room": "SingletonRoom",
#       "rate": "12000"
#     }
#   ]
# }
#
# Return formats:
# - fetch_rate: Returns a single rate value (Integer or String) or nil if not found
# - fetch_rates: Returns nested dictionary: rates[period][hotel][room] = rate_value or {} if error
class RateApiClient
    DEFAULT_TIMEOUT_SECONDS = 30

    def initialize(base_url: AppSettings.rate_api_url, timeout_seconds: DEFAULT_TIMEOUT_SECONDS)
        @base_url = base_url
        @timeout_seconds = timeout_seconds
    end

    # Fetch rate values for multiple requests. Returns nested dictionary of rates.
    # If unable to fetch rates, it will return an empty hash.
    # @param requests [Array<Hash>] Array of request objects with period:, hotel:, room: keys
    # @return [Hash] Nested dictionary: rates[period][hotel][room] = rate_value or {} if error
    def fetch_rates(requests)
        Sentry.with_child_span(op: "RateApiClient#fetch_rates", description: "fetch rates from rate API") do |span|
            span&.set_data("request_count", requests.length)

            begin
                uri = build_post_uri()
                http = Net::HTTP.new(uri.host, uri.port)
                http.open_timeout = @timeout_seconds
                http.read_timeout = @timeout_seconds

                request = Net::HTTP::Post.new(uri.request_uri)
                request['Content-Type'] = 'application/json'
                request['token'] = AppSettings.rate_api_token
                request.body = JSON.generate({ attributes: requests })

                response = http.request(request)

                unless response.is_a?(Net::HTTPSuccess)
                    Rails.logger.warn "Rate API HTTP error: #{response.code} #{response.body}"
                    return {}
                end

                parse_rates(response.body)
            rescue StandardError => e
                Rails.logger.warn "Rate API client error: #{e.message}"
                return {}
            end
        end
    end

    # Fetch rate value for given attributes. Returns Integer or String depending on backend.
    #
    # This method utilizes fetch_rates internally to leverage the API's batch processing capability.
    # Even for single requests, this ensures consistency and allows for potential future optimizations
    # where single requests can be batched together if called in rapid succession.
    #
    # Returns nil if rate cannot be fetched.
    def fetch_rate(period:, hotel:, room:)
        requests = [{ period: period, hotel: hotel, room: room }]
        rates_dict = fetch_rates(requests)

        # Extract the specific rate from the nested dictionary
        if rates_dict.key?(period) &&
           rates_dict[period].key?(hotel) &&
           rates_dict[period][hotel].key?(room)
            return rates_dict[period][hotel][room]
        end

        # Rate not found in expected structure - return nil safely
        Rails.logger.warn "Rate not found for #{period}/#{hotel}/#{room}"
        nil
    end

    # Builds the URI for the POST request.
    # @return [URI] The URI for the POST request
    def build_post_uri()
        uri = URI.parse(@base_url)
        uri.path = File.join(uri.path.empty? ? '/' : uri.path, 'pricing')
        uri
    end

    # Parses the API response and returns a nested dictionary of rates.
    # If unable to parse the response, it will return an empty hash.
    # @param body [String] The API response body
    # @return [Hash] Nested dictionary: rates[period][hotel][room] = rate_value or {} if error
    def parse_rates(body)
        Sentry.with_child_span(op: "RateApiClient#parse_rates", description: "parse rate API response") do |span|
            begin
                parsed = JSON.parse(body)
            rescue JSON::ParserError
                Rails.logger.warn "Failed to parse API response JSON"
                return {}
            end

            # Handle different response formats for multiple rates
            if parsed.is_a?(Hash) && parsed['rates'].is_a?(Array)
                rates = parsed['rates']
            else
                Rails.logger.warn "Unexpected API response format: #{parsed.class}"
                return {}
            end

            # Build nested dictionary structure: rates[period][hotel][room] = rate
            result = {}
            rates.each do |item|
                if item.is_a?(Hash) && item.key?('rate') && item.key?('period') && item.key?('hotel') && item.key?('room')
                    period = item['period']
                    hotel = item['hotel']
                    room = item['room']
                    rate = item['rate']

                    # Initialize nested structure
                    result[period] ||= {}
                    result[period][hotel] ||= {}
                    result[period][hotel][room] = rate
                else
                    Rails.logger.warn "Malformed rate item: #{item.inspect}"
                    # Skip malformed items, continue processing
                end
            end

            result
        end
    end
end


