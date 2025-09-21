# frozen_string_literal: true

# Build a standard RFC 7807 Problem Details object for validation failures.
# See: https://datatracker.ietf.org/doc/html/rfc7807#section-3
#
# This creates a JSON-serializable Hash shaped like:
# {
#   "type": "https://datatracker.ietf.org/doc/html/rfc7231#section-6.5.1",
#   "title": "One or more validation errors occurred.",
#   "traceId": "...optional trace id...",
#   "instance": "/path/of/request",
#   "errors": {
#     "fieldName": ["message1", "message2"]
#   }
# }
#
# Notes:
# - `errors` is a map of field name -> array of human-readable messages.
module ProblemDetails
  module_function

  DEFAULT_TYPE_FOR_400 = 'https://datatracker.ietf.org/doc/html/rfc7231#section-6.5.1'.freeze
  DEFAULT_VALIDATION_TITLE = 'One or more validation errors occurred.'.freeze
  DEFAULT_TYPE_FOR_503 = 'https://datatracker.ietf.org/doc/html/rfc7231#section-6.6.4'.freeze
  DEFAULT_SERVICE_UNAVAILABLE_TITLE = 'Service Temporarily Unavailable'.freeze

  def validation_error(errors:, title: DEFAULT_VALIDATION_TITLE, type: DEFAULT_TYPE_FOR_400, instance: nil, trace_id: nil)
    problem = {
      type: type,
      title: title,
      errors: errors
    }

    problem[:instance] = instance if instance
    problem[:traceId] = trace_id if trace_id

    problem
  end

  def service_unavailable_error(title: DEFAULT_SERVICE_UNAVAILABLE_TITLE, type: DEFAULT_TYPE_FOR_503, instance: nil, trace_id: nil)
    problem = {
      type: type,
      title: title,
    }

    problem[:instance] = instance if instance
    problem[:traceId] = trace_id if trace_id

    problem
  end
end
