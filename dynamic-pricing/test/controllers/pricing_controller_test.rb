require "test_helper"

class PricingControllerTest < ActionDispatch::IntegrationTest
  test "should get pricing with all parameters" do
    get pricing_url, params: {
      period: "Summer",
      hotel: "FloatingPointResort",
      room: "SingletonRoom"
    }

    assert_response :success
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_equal "12000", json_response["rate"]
  end

  test "should return error without any parameters" do
    get pricing_url

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_equal 400, json_response["status"]
    assert_equal "One or more validation errors occurred.", json_response["title"]
    assert json_response.key?("errors")
    assert_equal ["The period field is required."], json_response["errors"]["period"]
    assert_equal ["The hotel field is required."], json_response["errors"]["hotel"]
    assert_equal ["The room field is required."], json_response["errors"]["room"]
  end

  test "should handle empty parameters" do
    get pricing_url, params: {
      period: "",
      hotel: "",
      room: ""
    }

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_equal 400, json_response["status"]
    assert json_response.key?("errors")
    assert_equal ["The period field is required."], json_response["errors"]["period"]
    assert_equal ["The hotel field is required."], json_response["errors"]["hotel"]
    assert_equal ["The room field is required."], json_response["errors"]["room"]
  end

  test "should reject invalid period" do
    get pricing_url, params: {
      period: "summer-2024",
      hotel: "FloatingPointResort",
      room: "SingletonRoom"
    }

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_equal 400, json_response["status"]
    assert_equal ["The period field must be one of: Summer, Autumn, Winter, Spring."], json_response["errors"]["period"]
    assert_not json_response["errors"].key?("hotel"), "Expected only period to have errors"
    assert_not json_response["errors"].key?("room"), "Expected only period to have errors"
  end

  test "should reject invalid hotel" do
    get pricing_url, params: {
      period: "Summer",
      hotel: "InvalidHotel",
      room: "SingletonRoom"
    }

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_equal 400, json_response["status"]
    assert_equal ["The hotel field must be one of: FloatingPointResort, GitawayHotel, RecursionRetreat."], json_response["errors"]["hotel"]
    assert_not json_response["errors"].key?("period"), "Expected only hotel to have errors"
    assert_not json_response["errors"].key?("room"), "Expected only hotel to have errors"
  end

  test "should reject invalid room" do
    get pricing_url, params: {
      period: "Summer",
      hotel: "FloatingPointResort",
      room: "InvalidRoom"
    }

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_equal 400, json_response["status"]
    assert_equal ["The room field must be one of: SingletonRoom, BooleanTwin, RestfulKing."], json_response["errors"]["room"]
    assert_not json_response["errors"].key?("period"), "Expected only room to have errors"
    assert_not json_response["errors"].key?("hotel"), "Expected only room to have errors"
  end
end
