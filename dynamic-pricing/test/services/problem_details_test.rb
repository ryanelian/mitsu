# frozen_string_literal: true

require "test_helper"

class ProblemDetailsTest < ActiveSupport::TestCase
  test "validation_error creates basic problem details structure" do
    errors = { "field1" => ["error1", "error2"] }
    
    result = ProblemDetails.validation_error(errors: errors)
    
    assert_equal ProblemDetails::DEFAULT_TYPE_FOR_400, result[:type]
    assert_equal ProblemDetails::DEFAULT_VALIDATION_TITLE, result[:title]
    assert_equal errors, result[:errors]
    assert_nil result[:instance]
    assert_nil result[:traceId]
  end

  test "validation_error includes optional parameters when provided" do
    errors = { "email" => ["is required"] }
    title = "Custom validation title"
    type = "custom://validation-error"
    instance = "/api/users"
    trace_id = "trace-123"
    
    result = ProblemDetails.validation_error(
      errors: errors,
      title: title,
      type: type,
      instance: instance,
      trace_id: trace_id
    )
    
    assert_equal type, result[:type]
    assert_equal title, result[:title]
    assert_equal errors, result[:errors]
    assert_equal instance, result[:instance]
    assert_equal trace_id, result[:traceId]
  end

  test "validation_error with multiple field errors" do
    errors = {
      "email" => ["is required", "must be valid format"],
      "password" => ["is too short"],
      "name" => ["cannot be blank"]
    }
    
    result = ProblemDetails.validation_error(errors: errors)
    
    assert_equal errors, result[:errors]
    assert_equal 3, result[:errors].keys.length
  end

  test "service_unavailable_error creates basic problem details structure" do
    result = ProblemDetails.service_unavailable_error
    
    assert_equal ProblemDetails::DEFAULT_TYPE_FOR_503, result[:type]
    assert_equal ProblemDetails::DEFAULT_SERVICE_UNAVAILABLE_TITLE, result[:title]
    assert_nil result[:instance]
    assert_nil result[:traceId]
    refute result.key?(:errors)
  end

  test "service_unavailable_error includes optional parameters when provided" do
    title = "Custom service unavailable"
    type = "custom://service-unavailable"
    instance = "/api/rates"
    trace_id = "trace-456"
    
    result = ProblemDetails.service_unavailable_error(
      title: title,
      type: type,
      instance: instance,
      trace_id: trace_id
    )
    
    assert_equal type, result[:type]
    assert_equal title, result[:title]
    assert_equal instance, result[:instance]
    assert_equal trace_id, result[:traceId]
  end

  test "constants are defined correctly" do
    assert_equal 'https://datatracker.ietf.org/doc/html/rfc7231#section-6.5.1', ProblemDetails::DEFAULT_TYPE_FOR_400
    assert_equal 'One or more validation errors occurred.', ProblemDetails::DEFAULT_VALIDATION_TITLE
    assert_equal 'https://datatracker.ietf.org/doc/html/rfc7231#section-6.6.4', ProblemDetails::DEFAULT_TYPE_FOR_503
    assert_equal 'Service Temporarily Unavailable', ProblemDetails::DEFAULT_SERVICE_UNAVAILABLE_TITLE
  end

  test "validation_error returns hash that can be serialized to JSON" do
    errors = { "field" => ["error"] }
    result = ProblemDetails.validation_error(errors: errors)
    
    json_string = result.to_json
    parsed = JSON.parse(json_string)
    
    assert_equal result[:type], parsed["type"]
    assert_equal result[:title], parsed["title"]
    assert_equal result[:errors], parsed["errors"]
  end

  test "service_unavailable_error returns hash that can be serialized to JSON" do
    result = ProblemDetails.service_unavailable_error
    
    json_string = result.to_json
    parsed = JSON.parse(json_string)
    
    assert_equal result[:type], parsed["type"]
    assert_equal result[:title], parsed["title"]
  end
end