# frozen_string_literal: true

require "test_helper"

class ValidationHelpersTest < ActiveSupport::TestCase
  test "validate_set_value_field returns error when value is nil" do
    result = ValidationHelpers.validate_set_value_field(
      value: nil,
      field_key: "period",
      field_label: "Period",
      allowed_set: ["Summer", "Winter"],
      allowed_csv: "Summer, Winter"
    )
    
    assert_equal ["The Period field is required."], result
  end

  test "validate_set_value_field returns error when value is empty string" do
    result = ValidationHelpers.validate_set_value_field(
      value: "",
      field_key: "period",
      field_label: "Period",
      allowed_set: ["Summer", "Winter"],
      allowed_csv: "Summer, Winter"
    )
    
    assert_equal ["The Period field is required."], result
  end

  test "validate_set_value_field returns error when value is blank string" do
    result = ValidationHelpers.validate_set_value_field(
      value: "   ",
      field_key: "period",
      field_label: "Period",
      allowed_set: ["Summer", "Winter"],
      allowed_csv: "Summer, Winter"
    )
    
    assert_equal ["The Period field is required."], result
  end

  test "validate_set_value_field returns error when value not in allowed set" do
    result = ValidationHelpers.validate_set_value_field(
      value: "Spring",
      field_key: "period",
      field_label: "Period",
      allowed_set: ["Summer", "Winter"],
      allowed_csv: "Summer, Winter"
    )
    
    assert_equal ["The Period field must be one of: Summer, Winter."], result
  end

  test "validate_set_value_field returns nil when value is valid" do
    result = ValidationHelpers.validate_set_value_field(
      value: "Summer",
      field_key: "period",
      field_label: "Period",
      allowed_set: ["Summer", "Winter"],
      allowed_csv: "Summer, Winter"
    )
    
    assert_nil result
  end

  test "validate_set_value_field works with different field labels" do
    result = ValidationHelpers.validate_set_value_field(
      value: nil,
      field_key: "hotel",
      field_label: "Hotel Name",
      allowed_set: ["Hotel1", "Hotel2"],
      allowed_csv: "Hotel1, Hotel2"
    )
    
    assert_equal ["The Hotel Name field is required."], result
  end

  test "validate_set_value_field works with different allowed sets" do
    result = ValidationHelpers.validate_set_value_field(
      value: "InvalidRoom",
      field_key: "room",
      field_label: "Room Type",
      allowed_set: ["Single", "Double", "Suite"],
      allowed_csv: "Single, Double, Suite"
    )
    
    assert_equal ["The Room Type field must be one of: Single, Double, Suite."], result
  end

  test "validate_set_value_field is case sensitive" do
    result = ValidationHelpers.validate_set_value_field(
      value: "summer",
      field_key: "period",
      field_label: "Period",
      allowed_set: ["Summer", "Winter"],
      allowed_csv: "Summer, Winter"
    )
    
    assert_equal ["The Period field must be one of: Summer, Winter."], result
  end

  test "validate_set_value_field works with numeric strings" do
    result = ValidationHelpers.validate_set_value_field(
      value: "1",
      field_key: "level",
      field_label: "Level",
      allowed_set: ["1", "2", "3"],
      allowed_csv: "1, 2, 3"
    )
    
    assert_nil result
  end

  test "validate_set_value_field handles single item set" do
    result = ValidationHelpers.validate_set_value_field(
      value: "OnlyOption",
      field_key: "option",
      field_label: "Option",
      allowed_set: ["OnlyOption"],
      allowed_csv: "OnlyOption"
    )
    
    assert_nil result
  end

  test "validate_set_value_field handles empty allowed set" do
    result = ValidationHelpers.validate_set_value_field(
      value: "AnyValue",
      field_key: "field",
      field_label: "Field",
      allowed_set: [],
      allowed_csv: ""
    )
    
    assert_equal ["The Field field must be one of: ."], result
  end
end