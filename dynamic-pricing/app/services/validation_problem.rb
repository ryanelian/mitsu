# frozen_string_literal: true

# Build a standard RFC 7807 Problem Details object for validation failures.
# See: https://datatracker.ietf.org/doc/html/rfc7807#section-3
#
# This creates a JSON-serializable Hash shaped like:
# {
#   "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
#   "title": "One or more validation errors occurred.",
#   "status": 400,
#   "traceId": "...optional trace id...",
#   "instance": "/path/of/request",
#   "errors": {
#     "fieldName": ["message1", "message2"]
#   }
# }
#
# Notes:
# - We default the RFC 7231 400 reference into `type` for client error semantics, matching
#   common conventions for validation failures.
# - `errors` is a map of field name -> array of human-readable messages.
# - The hash is intentionally not frozen so Rails can safely serialize it.
module ValidationProblem
  module_function

  DEFAULT_TYPE_FOR_400 = 'https://tools.ietf.org/html/rfc7231#section-6.5.1'.freeze
  DEFAULT_VALIDATION_TITLE = 'One or more validation errors occurred.'.freeze

  def build_validation_error(errors:, status: 400, title: DEFAULT_VALIDATION_TITLE, type: DEFAULT_TYPE_FOR_400, instance: nil, trace_id: nil)
    problem = {
      type: type,
      title: title,
      status: status,
      errors: errors
    }

    problem[:instance] = instance if instance
    problem[:traceId] = trace_id if trace_id

    problem
  end
end
