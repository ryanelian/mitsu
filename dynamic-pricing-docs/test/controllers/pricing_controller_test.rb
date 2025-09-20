# This is a Rails integration test file using Minitest (built into Rails).
# If you're coming from ASP.NET Core, think of this as analogous to using WebApplicationFactory
# and HttpClient to make end-to-end HTTP requests against your app. Rails provides helpers
# like `get`, `post`, etc., plus assertions for the response.
# The tests below exercise the PricingController's `pricing` endpoint by issuing GET requests
# with various query parameters and validating the JSON responses and HTTP status codes.

require "test_helper"  # Loads the Rails test environment and Minitest setup. Similar to a test bootstrap in xUnit/NUnit.

# This test class inherits from ActionDispatch::IntegrationTest, which allows full-stack requests.
# - It spins up the routing, middleware, and controller stack (not hitting a real network socket).
# - Path helpers like `pricing_url` come from Rails routes (like Url.Action in ASP.NET).
class PricingControllerTest < ActionDispatch::IntegrationTest
  # Test: all parameters provided and valid should return a success (HTTP 200) with a JSON body.
  # Mirrors an integration test in C# where you'd call GET /pricing?period=...&hotel=...&room=...
  test "should get pricing with all parameters" do
    get pricing_url, params: {              # `get` issues an HTTP GET to the URL helper; `params` become query string.
      period: "Summer",                     # Ruby Hash literal; keys are symbols/strings—Rails will stringify keys internally.
      hotel: "FloatingPointResort",
      room: "SingletonRoom"
    }

    assert_response :success                # Symbolic status; :success == HTTP 200. Similar to Assert.Equal(HttpStatusCode.OK, ...).
    assert_equal "application/json", @response.media_type  # Content-Type without charset. Ensures JSON response.

    json_response = JSON.parse(@response.body) # Parse JSON string into a Ruby Hash (string keys by default).
    assert_equal "12000", json_response["rate"] # Expect rate as a string; match exactly to preserve type expectations.
  end

  # Test: no parameters at all should be treated as a bad request (HTTP 400) with an error message.
  test "should return error without any parameters" do
    get pricing_url                          # No `params` passed => no query string. Equivalent to GET /pricing.

    assert_response :bad_request             # :bad_request == HTTP 400.
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_includes json_response["error"], "Missing required parameters" # Substring check; message contains this text.
  end

  # Test: empty strings for parameters should be rejected (still a bad request).
  # In Rails, params present but blank often validated with presence checks (like .present?).
  test "should handle empty parameters" do
    get pricing_url, params: {
      period: "",                            # Empty string; treated as blank (falsy in validation, but truthy as a Ruby value).
      hotel: "",
      room: ""
    }

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_includes json_response["error"], "Missing required parameters"
  end

  # Test: invalid period value should be rejected with HTTP 400 and specific error text.
  test "should reject invalid period" do
    get pricing_url, params: {
      period: "summer-2024",                 # Not a valid enumerated value; controller likely checks allowed set like ["Summer", ...].
      hotel: "FloatingPointResort",
      room: "SingletonRoom"
    }

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_includes json_response["error"], "Invalid period"
  end

  # Test: invalid hotel value should be rejected with HTTP 400 and specific error text.
  test "should reject invalid hotel" do
    get pricing_url, params: {
      period: "Summer",
      hotel: "InvalidHotel",                 # Not in the allowed hotels list; expect validation failure.
      room: "SingletonRoom"
    }

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_includes json_response["error"], "Invalid hotel"
  end

  # Test: invalid room value should be rejected with HTTP 400 and specific error text.
  test "should reject invalid room" do
    get pricing_url, params: {
      period: "Summer",
      hotel: "FloatingPointResort",
      room: "InvalidRoom"                    # Not in allowed room types; controller should flag it.
    }

    assert_response :bad_request
    assert_equal "application/json", @response.media_type

    json_response = JSON.parse(@response.body)
    assert_includes json_response["error"], "Invalid room"
  end
end