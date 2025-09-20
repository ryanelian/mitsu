# Controller for pricing-related endpoints.
# Audience note (C#/TypeScript background):
# - This is analogous to an ASP.NET Core Controller or a Next.js API route handler.
# - Ruby is dynamically typed; you won't see type annotations here.
# - Rails controllers inherit from ApplicationController, which provides utilities like params, render, and filters.
class PricingController < ApplicationController
  # Immutable "constants" holding allowed values for request validation.
  # - %w[...] is a Ruby literal for an Array of Strings (space-separated); similar to ["Summer", "Autumn", ...].
  # - .freeze prevents further modification at runtime (roughly like making a read-only collection).
  VALID_PERIODS = %w[Summer Autumn Winter Spring].freeze   # Allowed seasonal periods
  VALID_HOTELS  = %w[FloatingPointResort GitawayHotel RecursionRetreat].freeze # Allowed hotel identifiers
  VALID_ROOMS   = %w[SingletonRoom BooleanTwin RestfulKing].freeze             # Allowed room types

  # before_action is a Rails controller "filter" (middleware-like) that runs before the action method.
  # - The symbol :validate_params refers to the private method defined below.
  # - If validate_params renders a response and returns, Rails will halt and not call the action (index).
  before_action :validate_params  # Equivalent idea: an ASP.NET Core action filter executing before the endpoint method

  # Default RESTful action name "index".
  # - For a GET /pricing?period=...&hotel=...&room=..., Rails routes typically map to this action.
  # - Instance variables (@var) would be available to views; here we just use locals and render JSON directly.
  def index
    period = params[:period]  # params is a Hash-like object provided by Rails (merged query string, route, body). Values are Strings by default.
    hotel  = params[:hotel]   # ActiveSupport gives params "indifferent access" (string/symbol keys both work), but here we use strings explicitly.
    room   = params[:room]

    # TODO: Start to implement here
    # render serializes the Ruby Hash to JSON and sets Content-Type: application/json.
    # Note: rate is deliberately a String ("12000"), not an Integer; preserving exact behavior.
    render json: { rate: "12000" }  # HTTP 200 OK by default unless status is specified
  end

  private

  # Validates presence and allowed values for required parameters.
  # - present? is an ActiveSupport helper: returns false for nil, empty string, or blank collections (roughly !nil && !empty).
  # - On validation failure, we immediately render a JSON error and return, which stops the filter chain and the action.
  # - status: :bad_request maps to HTTP 400 (Rails translates symbols to numeric codes).
  def validate_params
    # Validate required parameters
    unless params[:period].present? && params[:hotel].present? && params[:room].present?
      return render json: { error: "Missing required parameters: period, hotel, room" }, status: :bad_request  # Halt with 400 if any parameter is missing/blank
    end

    # Validate parameter values
    unless VALID_PERIODS.include?(params[:period])  # include? checks membership in the Array (O(n)); fine for small enums
      return render json: { error: "Invalid period. Must be one of: #{VALID_PERIODS.join(', ')}" }, status: :bad_request  # join builds a comma-separated list
    end

    unless VALID_HOTELS.include?(params[:hotel])
      return render json: { error: "Invalid hotel. Must be one of: #{VALID_HOTELS.join(', ')}" }, status: :bad_request
    end

    unless VALID_ROOMS.include?(params[:room])
      return render json: { error: "Invalid room. Must be one of: #{VALID_ROOMS.join(', ')}" }, status: :bad_request
    end
  end
end