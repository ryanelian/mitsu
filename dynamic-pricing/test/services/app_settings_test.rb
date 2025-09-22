# frozen_string_literal: true

require "test_helper"

class AppSettingsTest < ActiveSupport::TestCase
  test "redis_url returns REDIS_URL environment variable" do
    original_value = ENV["REDIS_URL"]
    ENV["REDIS_URL"] = "redis://test:6379"
    
    assert_equal "redis://test:6379", AppSettings.redis_url
  ensure
    ENV["REDIS_URL"] = original_value
  end

  test "redis_url raises error when REDIS_URL is missing" do
    original_value = ENV["REDIS_URL"]
    ENV.delete("REDIS_URL")
    
    error = assert_raises(RuntimeError) { AppSettings.redis_url }
    assert_equal "Missing required environment variable: REDIS_URL", error.message
  ensure
    ENV["REDIS_URL"] = original_value
  end

  test "redis_url raises error when REDIS_URL is blank" do
    original_value = ENV["REDIS_URL"]
    ENV["REDIS_URL"] = "   "
    
    error = assert_raises(RuntimeError) { AppSettings.redis_url }
    assert_equal "Missing required environment variable: REDIS_URL", error.message
  ensure
    ENV["REDIS_URL"] = original_value
  end

  test "rate_api_url returns RATE_API_URL environment variable" do
    original_value = ENV["RATE_API_URL"]
    ENV["RATE_API_URL"] = "http://api.test.com"
    
    assert_equal "http://api.test.com", AppSettings.rate_api_url
  ensure
    ENV["RATE_API_URL"] = original_value
  end

  test "rate_api_token returns RATE_API_TOKEN environment variable" do
    original_value = ENV["RATE_API_TOKEN"]
    ENV["RATE_API_TOKEN"] = "test_token_123"
    
    assert_equal "test_token_123", AppSettings.rate_api_token
  ensure
    ENV["RATE_API_TOKEN"] = original_value
  end

  test "rate_api_quota returns RATE_API_QUOTA as integer" do
    original_value = ENV["RATE_API_QUOTA"]
    ENV["RATE_API_QUOTA"] = "1000"
    
    assert_equal 1000, AppSettings.rate_api_quota
  ensure
    ENV["RATE_API_QUOTA"] = original_value
  end

  test "rate_api_quota converts string to integer" do
    original_value = ENV["RATE_API_QUOTA"]
    ENV["RATE_API_QUOTA"] = "500"
    
    result = AppSettings.rate_api_quota
    assert_equal 500, result
    assert_instance_of Integer, result
  ensure
    ENV["RATE_API_QUOTA"] = original_value
  end

  test "require_env! raises error for missing environment variable" do
    ENV.delete("TEST_MISSING_VAR")
    
    error = assert_raises(RuntimeError) { AppSettings.require_env!("TEST_MISSING_VAR") }
    assert_equal "Missing required environment variable: TEST_MISSING_VAR", error.message
  end

  test "require_env! raises error for empty environment variable" do
    ENV["TEST_EMPTY_VAR"] = ""
    
    error = assert_raises(RuntimeError) { AppSettings.require_env!("TEST_EMPTY_VAR") }
    assert_equal "Missing required environment variable: TEST_EMPTY_VAR", error.message
  ensure
    ENV.delete("TEST_EMPTY_VAR")
  end

  test "require_env! returns value for valid environment variable" do
    ENV["TEST_VALID_VAR"] = "valid_value"
    
    assert_equal "valid_value", AppSettings.require_env!("TEST_VALID_VAR")
  ensure
    ENV.delete("TEST_VALID_VAR")
  end
end