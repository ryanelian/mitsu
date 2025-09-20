# frozen_string_literal: true

# The "frozen_string_literal" magic comment is a common Ruby optimization that makes all string
# literals in this file immutable (similar in spirit to using readonly string constants in C#.
# It is safe to include and does not change runtime behavior of this class.
require 'set'

class PricingController < ApplicationController
  before_action :validate_params

  def index
    period = params[:period]
    hotel  = params[:hotel]
    room   = params[:room]

    # TODO: Start to implement here
    render json: { rate: "12000" }
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

    problem = ValidationProblem.build_validation_error(
      errors: errors,
      status: 400,
      instance: instance,
      trace_id: trace_id
    )

    { json: problem, status: :bad_request }
  end
end
