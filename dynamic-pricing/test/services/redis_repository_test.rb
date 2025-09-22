# frozen_string_literal: true

require "test_helper"

class RedisRepositoryTest < ActiveSupport::TestCase
  def setup
    @repo = RedisRepository.instance
    # Clean up any existing test data
    cleanup_test_keys
  end

  def teardown
    cleanup_test_keys
  end

  test "instance returns singleton" do
    repo1 = RedisRepository.instance
    repo2 = RedisRepository.instance
    
    assert_same repo1, repo2
  end

  test "ping returns true when Redis is available" do
    result = @repo.ping
    assert_equal true, result
  end

  test "get returns nil for non-existent key" do
    result = @repo.get("non_existent_key")
    assert_nil result
  end

  test "set and get work correctly" do
    key = "test_key_#{SecureRandom.hex(4)}"
    value = "test_value"
    
    @repo.set(key, 60, value)
    result = @repo.get(key)
    
    assert_equal value, result
  end

  test "set with TTL expires after specified time" do
    key = "test_ttl_key_#{SecureRandom.hex(4)}"
    value = "test_value"
    
    @repo.set(key, 1, value)  # 1 second TTL
    assert_equal value, @repo.get(key)
    
    sleep(1.1)  # Wait for expiration
    assert_nil @repo.get(key)
  end

  test "increment creates and increments counter" do
    key = "test_counter_#{SecureRandom.hex(4)}"
    
    result1 = @repo.increment(key)
    assert_equal 1, result1
    
    result2 = @repo.increment(key)
    assert_equal 2, result2
  end

  test "increment_by increments counter by specified amount" do
    key = "test_counter_by_#{SecureRandom.hex(4)}"
    
    result1 = @repo.increment_by(key, 5)
    assert_equal 5, result1
    
    result2 = @repo.increment_by(key, 3)
    assert_equal 8, result2
  end

  test "get_counter returns 0 for non-existent counter" do
    key = "non_existent_counter"
    result = @repo.get_counter(key)
    assert_equal 0, result
  end

  test "get_counter returns current counter value" do
    key = "test_get_counter_#{SecureRandom.hex(4)}"
    
    @repo.increment_by(key, 10)
    result = @repo.get_counter(key)
    
    assert_equal 10, result
  end

  test "add_to_set and get_set_members work correctly" do
    set_key = "test_set_#{SecureRandom.hex(4)}"
    
    @repo.add_to_set(set_key, "member1")
    @repo.add_to_set(set_key, "member2")
    @repo.add_to_set(set_key, "member1")  # Duplicate should be ignored
    
    members = @repo.get_set_members(set_key)
    
    assert_equal 2, members.length
    assert_includes members, "member1"
    assert_includes members, "member2"
  end

  test "get_set_members returns empty array for non-existent set" do
    result = @repo.get_set_members("non_existent_set")
    assert_equal [], result
  end

  test "get_lock_key generates correct lock key format" do
    resource = "test_resource"
    lock_key = @repo.get_lock_key(resource)
    
    assert_equal "lock:test_resource", lock_key
  end

  test "lock acquires and returns token" do
    resource = "test_lock_resource_#{SecureRandom.hex(4)}"
    
    token = @repo.lock(resource, ttl_milliseconds: 5000)
    
    assert_not_nil token
    assert_instance_of String, token
    assert token.length > 0
  end

  test "lock prevents concurrent access to same resource" do
    resource = "test_concurrent_resource_#{SecureRandom.hex(4)}"
    
    token1 = @repo.lock(resource, ttl_milliseconds: 2000)
    assert_not_nil token1
    
    # Second lock attempt should fail immediately
    token2 = @repo.lock(resource, ttl_milliseconds: 2000, retry_count: 1)
    assert_nil token2
  end

  test "unlock releases lock successfully" do
    resource = "test_unlock_resource_#{SecureRandom.hex(4)}"
    
    token = @repo.lock(resource, ttl_milliseconds: 5000)
    assert_not_nil token
    
    result = @repo.unlock(resource, token)
    assert_equal true, result
    
    # Should be able to acquire lock again
    new_token = @repo.lock(resource, ttl_milliseconds: 5000)
    assert_not_nil new_token
  end

  test "unlock fails with wrong token" do
    resource = "test_wrong_token_resource_#{SecureRandom.hex(4)}"
    
    token = @repo.lock(resource, ttl_milliseconds: 5000)
    assert_not_nil token
    
    result = @repo.unlock(resource, "wrong_token")
    assert_equal false, result
    
    # Original lock should still be held
    new_token = @repo.lock(resource, ttl_milliseconds: 1000, retry_count: 1)
    assert_nil new_token
  end

  test "with_lock executes block and releases lock" do
    resource = "test_with_lock_resource_#{SecureRandom.hex(4)}"
    executed = false
    
    result = @repo.with_lock(resource, ttl_milliseconds: 5000) do
      executed = true
      "block_result"
    end
    
    assert_equal true, executed
    assert_equal "block_result", result
    
    # Lock should be released - should be able to acquire again
    new_token = @repo.lock(resource, ttl_milliseconds: 1000)
    assert_not_nil new_token
  end

  test "with_lock releases lock even when block raises exception" do
    resource = "test_exception_resource_#{SecureRandom.hex(4)}"
    
    assert_raises(StandardError) do
      @repo.with_lock(resource, ttl_milliseconds: 5000) do
        raise StandardError, "test error"
      end
    end
    
    # Lock should be released despite exception
    token = @repo.lock(resource, ttl_milliseconds: 1000)
    assert_not_nil token
  end

  test "with_lock returns nil when lock cannot be acquired" do
    resource = "test_no_lock_resource_#{SecureRandom.hex(4)}"
    
    # Acquire lock first
    token = @repo.lock(resource, ttl_milliseconds: 2000)
    assert_not_nil token
    
    # Try to execute with_lock - should return nil
    result = @repo.with_lock(resource, ttl_milliseconds: 1000, retry_count: 1) do
      "should_not_execute"
    end
    
    assert_nil result
  end

  test "lock expires after TTL" do
    resource = "test_ttl_lock_resource_#{SecureRandom.hex(4)}"
    
    token = @repo.lock(resource, ttl_milliseconds: 500)  # 0.5 seconds
    assert_not_nil token
    
    sleep(0.6)  # Wait for expiration
    
    # Should be able to acquire lock again
    new_token = @repo.lock(resource, ttl_milliseconds: 1000)
    assert_not_nil new_token
  end

  private

  def cleanup_test_keys
    # Clean up test keys - this is a simple approach for testing
    # In production, you'd want more sophisticated cleanup
    test_keys = [
      "test_key_*",
      "test_ttl_key_*", 
      "test_counter_*",
      "test_counter_by_*",
      "test_get_counter_*",
      "test_set_*",
      "lock:test_*"
    ]
    
    # Note: This cleanup is basic - in a real test environment you might
    # want to use a separate Redis database or more sophisticated cleanup
  end
end