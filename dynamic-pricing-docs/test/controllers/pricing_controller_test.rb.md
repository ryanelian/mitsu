# Executive Summary
- File: test/controllers/pricing_controller_test.rb
- TL;DR: Integration tests for the PricingController JSON endpoint. Verifies success with valid params and :bad_request with missing/invalid params, including content type and specific JSON fields.

# Ruby Concepts
| Ruby Concept | What It Is | C#/TS Analogy |
| --- | --- | --- |
| Minitest `test` DSL | Defines a test case with a descriptive string and block | xUnit/NUnit `[Fact]` or MSTest `[TestMethod]` |
| Hash literal with symbol keys | `params: { period: "Summer" }` creates a Hash | C#: `Dictionary<string,string>`; TS: `{ [key: string]: string }` |
| Instance var `@response` | Test response object set by the framework | C#: `HttpResponseMessage` in integration tests |
| Symbols (e.g., `:success`) | Lightweight identifiers used in APIs | C#: `HttpStatusCode.OK`; TS enums/union string literals |
| `JSON.parse` | Parses JSON string into Ruby Hash/Array | C#: `System.Text.Json.JsonSerializer.Deserialize`; TS: `JSON.parse` |
| `assert_includes` | Checks substring or member presence | C#: `Assert.Contains`; TS/Jest: `expect(str).toContain(...)` |

# Rails Concepts
| Rails Concept | What It Is | ASP.NET/React Analogy |
| --- | --- | --- |
| ActionDispatch::IntegrationTest | Full-stack request tests hitting routing, controller, middleware | ASP.NET Core integration tests using WebApplicationFactory/HttpClient |
| Route helper `pricing_url` | Generates URL for the pricing route | ASP.NET Core URL helpers: `LinkGenerator/GetUriByAction` |
| `get ... , params:` | Issues HTTP GET with query params | `HttpClient.GetAsync` with query string |
| `assert_response` | Asserts HTTP status | `Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode)` |
| `@response.media_type` | Content type sans charset | `response.Content.Headers.ContentType.MediaType` |
| JSON response contract | Validates response shape and values | Validate DTO in response using deserialization in C# or fetch JSON in React tests |

# Code Anatomy
- class PricingControllerTest < ActionDispatch::IntegrationTest: Integration tests for PricingController.
- test "should get pricing with all parameters": Calls GET /pricing with valid period/hotel/room; expects 200, JSON, and rate "12000".
- test "should return error without any parameters": GET /pricing with no params; expects 400 and error message includes "Missing required parameters".
- test "should handle empty parameters": GET /pricing with empty strings; expects 400 and error message includes "Missing required parameters".
- test "should reject invalid period": GET /pricing with invalid period; expects 400 and error message includes "Invalid period".
- test "should reject invalid hotel": GET /pricing with invalid hotel; expects 400 and error message includes "Invalid hotel".
- test "should reject invalid room": GET /pricing with invalid room; expects 400 and error message includes "Invalid room".

# Critical Issues
No critical bugs found

# Performance Issues
No performance issues found

# Security Concerns
No security concerns found

# Suggestions for Improvements
- DRY JSON parsing into a helper to reduce repetition.
  - Rationale: Improves readability and consistency.
  - Before:
    ```ruby
    json_response = JSON.parse(@response.body)
    ```
  - After:
    ```ruby
    def json_body
      JSON.parse(response.body)
    end
    ```
- Prefer `response` over `@response` for clarity and modern style.
  - Rationale: `response` is the public API; `@response` is internal.
  - Example:
    ```ruby
    assert_equal "application/json", response.media_type
    json = JSON.parse(response.body)
    ```
- Use `setup` to centralize common expectations like content type.
  - Rationale: Reduces duplication.
  - Example:
    ```ruby
    setup do
      @json_media_type = "application/json"
    end
    ```
- Table-driven tests for invalid inputs to cut repetition.
  - Rationale: Easier to add new invalid cases.
  - Example:
    ```ruby
    [
      [{ period: "summer-2024", hotel: "FloatingPointResort", room: "SingletonRoom" }, "Invalid period"],
      [{ period: "Summer", hotel: "InvalidHotel",        room: "SingletonRoom" },       "Invalid hotel"],
      [{ period: "Summer", hotel: "FloatingPointResort", room: "InvalidRoom" },         "Invalid room"]
    ].each do |params, msg|
      test "rejects invalid input: #{msg}" do
        get pricing_url, params: params
        assert_response :bad_request
        assert_equal @json_media_type, response.media_type
        assert_includes JSON.parse(response.body)["error"], msg
      end
    end
    ```
- Consider asserting numeric types if the API intends numbers, not strings.
  - Rationale: Prevents accidental stringly-typed JSON.
  - Example:
    ```ruby
    json = JSON.parse(response.body)
    assert_equal 12000, json["rate"] # if API returns a number
    ```