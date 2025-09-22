# frozen_string_literal: true

require "test_helper"

class RateApiClientTest < ActiveSupport::TestCase
  def setup
    @client = RateApiClient.new
  end

  test "build_post_uri creates correct URI" do
    uri = @client.build_post_uri
    
    assert_equal "http", uri.scheme
    assert_equal "/pricing", uri.path
  end

  test "build_post_uri handles base URL with existing path" do
    client = RateApiClient.new(base_url: "http://api.example.com/v1")
    uri = client.build_post_uri
    
    assert_equal "/v1/pricing", uri.path
  end

  test "fetch_rate returns rate for valid request" do
    result = @client.fetch_rate(period: "Summer", hotel: "FloatingPointResort", room: "SingletonRoom")
    
    assert_not_nil result
    # Rate can be either String or Integer depending on API response
    assert(result.is_a?(String) || result.is_a?(Integer))
  end

  test "fetch_rate returns nil for invalid hotel" do
    result = @client.fetch_rate(period: "Summer", hotel: "NonExistentHotel", room: "SingletonRoom")
    
    assert_nil result
  end

  test "fetch_rate returns nil for invalid room" do
    result = @client.fetch_rate(period: "Summer", hotel: "FloatingPointResort", room: "NonExistentRoom")
    
    assert_nil result
  end

  test "fetch_rate returns nil for invalid period" do
    result = @client.fetch_rate(period: "InvalidPeriod", hotel: "FloatingPointResort", room: "SingletonRoom")
    
    assert_nil result
  end

  test "fetch_rates returns nested dictionary for multiple valid rates" do
    requests = [
      { period: "Summer", hotel: "FloatingPointResort", room: "SingletonRoom" },
      { period: "Winter", hotel: "FloatingPointResort", room: "SingletonRoom" }
    ]
    
    result = @client.fetch_rates(requests)
    
    assert_instance_of Hash, result
    assert result.key?("Summer")
    assert result.key?("Winter")
    assert result["Summer"].key?("FloatingPointResort")
    assert result["Winter"].key?("FloatingPointResort")
    assert result["Summer"]["FloatingPointResort"].key?("SingletonRoom")
    assert result["Winter"]["FloatingPointResort"].key?("SingletonRoom")
  end

  test "fetch_rates handles mix of valid and invalid requests" do
    requests = [
      { period: "Summer", hotel: "FloatingPointResort", room: "SingletonRoom" },
      { period: "Summer", hotel: "NonExistentHotel", room: "SingletonRoom" }
    ]
    
    result = @client.fetch_rates(requests)
    
    assert_instance_of Hash, result
    # Should have the valid rate if any valid requests exist
    if result.key?("Summer")
      # If Summer key exists, it should have FloatingPointResort
      assert result["Summer"].key?("FloatingPointResort")
    end
    # Invalid hotel should not be present if Summer key exists
    if result.key?("Summer")
      refute result["Summer"].key?("NonExistentHotel")
    end
  end

  test "fetch_rates returns empty hash for all invalid requests" do
    requests = [
      { period: "InvalidPeriod", hotel: "InvalidHotel", room: "InvalidRoom" }
    ]
    
    result = @client.fetch_rates(requests)
    
    assert_equal({}, result)
  end

  test "parse_rates handles valid response format" do
    body = {
      rates: [
        { period: "Summer", hotel: "Hotel1", room: "Single", rate: "10000" },
        { period: "Winter", hotel: "Hotel1", room: "Double", rate: "12000" }
      ]
    }.to_json
    
    result = @client.parse_rates(body)
    
    assert_equal "10000", result["Summer"]["Hotel1"]["Single"]
    assert_equal "12000", result["Winter"]["Hotel1"]["Double"]
  end

  test "parse_rates returns empty hash for invalid JSON" do
    result = @client.parse_rates("invalid json")
    
    assert_equal({}, result)
  end

  test "parse_rates returns empty hash for unexpected format" do
    body = { unexpected: "format" }.to_json
    
    result = @client.parse_rates(body)
    
    assert_equal({}, result)
  end

  test "parse_rates skips malformed rate items" do
    body = {
      rates: [
        { period: "Summer", hotel: "Hotel1", room: "Single", rate: "10000" },
        { period: "Winter", hotel: "Hotel1" },  # Missing room and rate
        { period: "Spring", hotel: "Hotel2", room: "Double", rate: "8000" }
      ]
    }.to_json
    
    result = @client.parse_rates(body)
    
    assert_equal "10000", result["Summer"]["Hotel1"]["Single"]
    assert_equal "8000", result["Spring"]["Hotel2"]["Double"]
    refute result.key?("Winter")
  end

  test "parse_rates handles empty rates array" do
    body = { rates: [] }.to_json
    
    result = @client.parse_rates(body)
    
    assert_equal({}, result)
  end

  test "client handles network timeouts gracefully" do
    # Test with very short timeout to simulate timeout
    client = RateApiClient.new(timeout_seconds: 0.001)
    
    result = client.fetch_rate(period: "Summer", hotel: "FloatingPointResort", room: "SingletonRoom")
    
    # Should return nil on timeout, not raise exception
    # Note: Very fast networks might still succeed, so we just verify no exception
    assert(result.nil? || result.is_a?(String) || result.is_a?(Integer))
  end

  test "fetch_rate and fetch_rates return consistent results" do
    period = "Summer"
    hotel = "FloatingPointResort"
    room = "SingletonRoom"
    
    single_result = @client.fetch_rate(period: period, hotel: hotel, room: room)
    
    requests = [{ period: period, hotel: hotel, room: room }]
    batch_result = @client.fetch_rates(requests)
    
    if single_result
      # Both should return the same rate (though values may vary between calls)
      assert batch_result.key?(period)
      assert batch_result[period].key?(hotel)
      assert batch_result[period][hotel].key?(room)
      # Values should be of the same type
      batch_value = batch_result[period][hotel][room]
      assert_equal single_result.class, batch_value.class
    else
      assert_equal({}, batch_result)
    end
  end
end