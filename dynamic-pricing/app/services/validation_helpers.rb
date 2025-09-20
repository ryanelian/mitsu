# frozen_string_literal: true

# Generic validation helpers reused across controllers/services.
#
# Conventions:
# - Presence is checked first; if missing, return a single message in an array.
# - If present, membership (or other constraints) are validated next.
# - Return an array of error messages when invalid, or nil when valid.
module ValidationHelpers
  module_function

  # Validates that a field is present and its value is contained in the allowed_set.
  # Returns ["error message"] or nil.
  def validate_set_value_field(value:, field_key:, field_label:, allowed_set:, allowed_csv:)
    unless value.present?
      return ["The #{field_label} field is required."]
    end

    unless allowed_set.include?(value)
      return ["The #{field_label} field must be one of: #{allowed_csv}."]
    end

    nil
  end
end


