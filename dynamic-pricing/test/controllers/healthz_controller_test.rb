# frozen_string_literal: true

require "test_helper"

class HealthzControllerTest < ActionDispatch::IntegrationTest
  test "healthz endpoint returns ok status" do
    get "/healthz"
    
    assert_response :success
    
    response_data = JSON.parse(response.body)
    
    assert_equal "ok", response_data["status"]
  end

  test "healthz endpoint returns redis status" do
    get "/healthz"
    
    assert_response :success
    
    response_data = JSON.parse(response.body)
    
    assert response_data.key?("redis")
    assert response_data["redis"].key?("ok")
    assert_equal true, response_data["redis"]["ok"]
  end

  test "healthz endpoint returns quota information" do
    get "/healthz"
    
    assert_response :success
    
    response_data = JSON.parse(response.body)
    
    assert response_data.key?("metrics")
    metrics = response_data["metrics"]
    
    assert metrics.key?("quota")
    assert metrics.key?("rate_api_calls_used")
    assert metrics.key?("rate_api_calls_remaining")
    assert metrics.key?("has_quota_remaining")
    assert metrics.key?("hit_count")
    
    # Verify quota is a positive number
    assert metrics["quota"] > 0
    
    # Verify remaining quota calculation
    expected_remaining = metrics["quota"] - metrics["rate_api_calls_used"]
    assert_equal expected_remaining, metrics["rate_api_calls_remaining"]
    
    # Verify has_quota_remaining is boolean
    assert [true, false].include?(metrics["has_quota_remaining"])
    
    # Verify hit_count is non-negative
    assert metrics["hit_count"] >= 0
  end

  test "healthz endpoint returns valid JSON structure" do
    get "/healthz"
    
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
    
    response_data = JSON.parse(response.body)
    
    # Verify top-level structure
    expected_keys = ["status", "redis", "metrics"]
    assert_equal expected_keys.sort, response_data.keys.sort
    
    # Verify redis structure
    assert_equal ["ok"], response_data["redis"].keys
    
    # Verify metrics structure
    expected_metric_keys = [
      "quota",
      "rate_api_calls_used", 
      "rate_api_calls_remaining",
      "has_quota_remaining",
      "hit_count"
    ]
    assert_equal expected_metric_keys.sort, response_data["metrics"].keys.sort
  end
end