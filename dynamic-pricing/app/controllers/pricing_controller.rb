# frozen_string_literal: true

# The "frozen_string_literal" magic comment is a common Ruby optimization that makes all string
# literals in this file immutable (similar in spirit to using readonly string constants in C#.
# It is safe to include and does not change runtime behavior of this class.
require 'set'

# PricingController serves the public pricing endpoint.
#
# Implements the Stale-While-Revalidate (SWR) caching strategy:
# - https://datatracker.ietf.org/doc/html/rfc5861
# - Fast path (stale data): If a requested (period, hotel, room) combination is cached,
#   `RateApiService.get_rate` returns it immediately.
# - Miss path: On cache miss, we acquire a short-lived distributed lock (per key), fetch from the
#   upstream API, store for 5 minutes, and return the fresh value. This prevents cache stampedes and
#   keeps the request path responsive rather than waiting for a background job.
# - Revalidation: A worker runs every 2 minutes to batch-refresh all previously requested keys.
#   If there are no cached keys, the worker does nothing.
#
# Quota and batching:
# - Upstream limit: 1000 calls/day.
# - 1 day = 24 hour x 60 minutes = 1440 minutes
#   With a 2-minute interval we have 720 cycles/day
# - The batch endpoint requires an array of parameter sets. For this API the domain is bounded:
#   4 periods × 3 hotels × 3 rooms = 36 maximum combinations.
# - Therefore, in a single day, the total number of API calls is bounded by 720 + 36 = 756.
class PricingController < ApplicationController
  before_action :validate_params

  def index
    period = params[:period]
    hotel  = params[:hotel]
    room   = params[:room]

    begin
      rate_value = RateApiService.get_rate(
        period: period,
        hotel: hotel,
        room: room
      )
      RateApiService.increment_hit_count()
      render json: { rate: rate_value }
    rescue RateApiService::ServiceUnavailableError => e
      render json: ProblemDetails.service_unavailable_error(
        instance: request.path,
        trace_id: request.request_id
      ), status: :service_unavailable
    end
  end

  private

  def validate_params
    if (error = PricingValidation.validate(params, instance: request.path, trace_id: request.request_id))
      return render json: error[:json], status: error[:status]
    end
  end
end

# Module for validating pricing parameters
# Pricing API requires the following parameters: period, hotel, room
# Each of these parameters has a set of allowed values
# When validation fails, an RFC 7807 Problem Details object is returned
module PricingValidation
  module_function

  # Use frozen Sets for O(1) membership checks and allocate them once at load time.
  # Keep small source arrays only to build human-readable error strings once (no per-request joins).
  PERIODS_LIST = %w[Summer Autumn Winter Spring].freeze
  VALID_PERIODS = PERIODS_LIST.to_set.freeze
  PERIODS_CSV = PERIODS_LIST.join(', ').freeze

  HOTELS_LIST = %w[FloatingPointResort GitawayHotel RecursionRetreat].freeze
  VALID_HOTELS = HOTELS_LIST.to_set.freeze
  HOTELS_CSV = HOTELS_LIST.join(', ').freeze

  ROOMS_LIST = %w[SingletonRoom BooleanTwin RestfulKing].freeze
  VALID_ROOMS = ROOMS_LIST.to_set.freeze
  ROOMS_CSV = ROOMS_LIST.join(', ').freeze

  # Validates the incoming params for the pricing endpoint and returns either:
  # - nil (no validation errors), or
  # - { json: <problem details hash>, status: :bad_request }
  #
  # Implementation notes:
  # - We accumulate errors per-field so clients can render them inline.
  # - We use Sets above for O(1) membership checks (faster than array include? O(N)).
  # - We precompute CSV lists for friendly error messages without per-request joins.
  def validate(params, instance:, trace_id:)
    errors = {}

    if (messages = ValidationHelpers.validate_set_value_field(value: params[:period], field_key: 'period', field_label: 'period', allowed_set: VALID_PERIODS, allowed_csv: PERIODS_CSV))
      errors['period'] = messages
    end

    if (messages = ValidationHelpers.validate_set_value_field(value: params[:hotel], field_key: 'hotel', field_label: 'hotel', allowed_set: VALID_HOTELS, allowed_csv: HOTELS_CSV))
      errors['hotel'] = messages
    end

    if (messages = ValidationHelpers.validate_set_value_field(value: params[:room], field_key: 'room', field_label: 'room', allowed_set: VALID_ROOMS, allowed_csv: ROOMS_CSV))
      errors['room'] = messages
    end

    return nil if errors.empty?

    problem = ProblemDetails.validation_error(
      errors: errors,
      instance: instance,
      trace_id: trace_id
    )

    { json: problem, status: :bad_request }
  end
end
