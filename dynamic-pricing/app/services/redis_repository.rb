# frozen_string_literal: true

require "redis"
require "securerandom"
require "digest"

# A singleton for accessing the Redis key-value store, implementing the repository pattern
class RedisRepository
    # gets the singleton instance
    def self.instance()
        @instance ||= new()
    end

    # private constructor
    private_class_method :new

    # Generates the lock key name for a given resource
    # Follows Redis best practices for key naming
    def get_lock_key(resource)
        "lock:#{resource}"
    end

    # Ping the Redis server. Returns true if successful, false otherwise.
    # Logs an error if the ping fails. Used in health check endpoint.
    def ping()
        begin
            if @client.ping() == "PONG"
                return true
            else
                Rails.logger.error "Redis ping failed"
            end
        rescue => e
            Rails.logger.error "Error pinging Redis: #{e}"
        end
        false
    end

    # Get a value by key (returns nil if missing)
    def get(key)
        @client.get(key)
    end

    # Set a value with TTL in seconds
    def set(key, ttl_seconds, value)
        @client.setex(key, ttl_seconds, value)
    end

    # Increment a counter by 1 and return the new value
    # Useful for tracking metrics like API call counts
    def increment(key)
        @client.incr(key)
    end

    # Increment a counter by a specific amount and return the new value
    # Useful for tracking metrics like API call counts
    def increment_by(key, amount)
        @client.incrby(key, amount)
    end

    # Get the current value of a counter
    def get_counter(key)
        value = @client.get(key)
        value ? value.to_i : 0
    end

    # Add a member to a Redis set
    def add_to_set(set_key, member)
        @client.sadd(set_key, member)
    end

    # Get all members of a Redis set
    def get_set_members(set_key)
        @client.smembers(set_key)
    end

    # ======================================================================
    # Redlock is a distributed locking algorithm designed to provide mutual exclusion
    # across multiple Redis instances. It works by attempting to acquire locks on
    # a majority of Redis servers to achieve consensus.
    #
    # Key concepts:
    # - Resource: The thing we're trying to lock (e.g., "rate_calculation")
    # - Token: A unique identifier for each lock attempt (prevents accidental unlocks)
    # - TTL: Time-to-live for the lock (prevents deadlocks if process crashes)
    # - Majority: Lock is only considered acquired if successful on >50% of Redis instances
    #
    # Algorithm steps:
    # 1. Generate unique token for this lock attempt
    # 2. Get current time in milliseconds
    # 3. Try to set lock on all Redis instances with TTL
    # 4. Check if lock was acquired on majority of instances
    # 5. If yes, lock is held; if no, release any partial locks and retry
    # 6. On release, only delete the key if it still contains our token
    #
    # In our single Redis setup, this simplifies but maintains the safety properties.
    # It is also applicable for Serverless Valkey services like AWS ElastiCache.
    # 
    # Reference:
    # - https://valkey.io/topics/distlock/
    # - https://redis.io/docs/latest/develop/clients/patterns/distributed-locks/
    # ======================================================================

    # Attempts to acquire a distributed lock using the Redlock algorithm
    #
    # @param resource [String] The resource to lock (e.g., "rate_calculation")
    # @param ttl_milliseconds [Integer] Lock TTL in milliseconds (default: 10000ms = 10s)
    # @param retry_count [Integer] Number of retry attempts (default: 3)
    # @param retry_delay_milliseconds [Integer] Delay between retries (default: 200ms)
    # @return [String, nil] Returns the lock token if successful, nil if failed
    def lock(resource, ttl_milliseconds: 10_000, retry_count: 3, retry_delay_milliseconds: 200)
        # Step 1: Generate a unique token for this lock attempt
        # This prevents accidental unlocks by other processes or retry attempts
        lock_token = generate_lock_token

        # Step 2: Attempt to acquire the lock with retries
        retry_count.times do |attempt|
            Rails.logger.debug "Redlock: Attempting to acquire lock for '#{resource}' (attempt #{attempt + 1}/#{retry_count})"

            # Step 3: Get current time for timing calculations
            start_time = current_time_milliseconds

            # Step 4: Try to set the lock key
            # We use SET with NX (only set if not exists) and PX (milliseconds TTL)
            lock_acquired = @client.set(
                resource,               # Key: "lock:#{resource}"
                lock_token,             # Value: our unique token
                nx: true,               # Only set if key doesn't exist (NX flag)
                px: ttl_milliseconds    # TTL in milliseconds (PX flag)
            )

            # Step 5: Check if lock was successfully acquired
            if lock_acquired
                Rails.logger.debug "Redlock: Successfully acquired lock for '#{resource}' with token '#{lock_token}'"
                return lock_token
            end

            # Step 6: Lock acquisition failed, wait before retry
            # Calculate elapsed time and implement constant retry delay (not exponential backoff)
            elapsed = current_time_milliseconds - start_time

            # Take the minimum of configured retry delay
            # and remaining TTL time to avoid sleeping longer than lock duration
            sleep_time = [retry_delay_milliseconds, ttl_milliseconds - elapsed].min / 1000.0
            sleep_time = [sleep_time, 0].max  # Ensure non-negative

            Rails.logger.debug "Redlock: Lock acquisition failed for '#{resource}', waiting #{sleep_time}s before retry (#{elapsed}ms elapsed, #{ttl_milliseconds - elapsed}ms remaining)"
            
            # Unlike languages with true async-await primitives (C#, JavaScript, Python, etc.),
            # Ruby lacks built-in cooperative concurrency mechanisms that can yield control
            # during an I/O wait without blocking the entire OS thread.

            # In C# / JavaScript / Python, the await keyword:
            # • Suspends the async method, returns the thread to the pool or event loop
            # • Enables other tasks to run on that thread during the delay (non-blocking)
            # • Provides O(1) context switches via a compiler-generated state machine
            # • Async/await excels by releasing threads during I/O, handling hundreds of
            #   requests per thread with minimal thread-pool usage

            # On the other hand, The GVL (Global VM Lock) in MRI (Matz’s Ruby Interpreter / CRuby)
            # serializes Ruby bytecode execution so that only one Ruby thread runs at a time.
            # Thread switching happens only at defined yield points or when a thread 
            # releases the GVL—typically around I/O system calls or explicit sleeps.
            # The consequences of these fundamental limitations are:
            # 1. CPU-bound tasks cannot take advantage of multiple cores.
            # 2. I/O-bound tasks do release the GVL (e.g., during blocking socket reads,
            #    database calls, or sleep), but they still block the entire OS thread.
            #    The scheduler must perform a very expensive OS-level context switch to wake another thread.

            # As a result, Ruby on Rails is not a good choice for concurrency.
            # The architectural limitations translate to significant production performance gaps:
            # • https://www.techempower.com/benchmarks/#section=data-r23&test=fortune
            # • ASP.NET Core (C#):     741,878 req/sec  (18x faster than Ruby)
            # • Node.js (JavaScript):  283,445 req/sec  (7x faster than Ruby)  
            # • Ruby on Rails:          42,546 req/sec  (baseline)
            
            # These benchmarks reflect real-world scenarios including request parsing,
            # database operations, and response serialization demonstrating that Ruby's
            # concurrency limitations require 7-18x more server instances for equivalent throughput.

            # In conclusion, this method call below will cause the thread to sleep for the amount of time specified
            # and Ruby / Rails will switch context to another thread for limited concurrency.
            # However, the thread that is sleeping is not returned to the thread pool and is not available to handle another request.
            # Unfortunately, this is the best we can do for now. Sleep well, old thread.
            sleep(sleep_time) if attempt < retry_count - 1
        end

        # Step 7: All retry attempts failed
        Rails.logger.warn "Redlock: Failed to acquire lock for '#{resource}' after #{retry_count} attempts"
        nil
    end

    # Releases a distributed lock using the Redlock algorithm
    #
    # @param resource [String] The resource to unlock (e.g., "rate_calculation")
    # @param token [String] The lock token returned by #lock
    # @return [Boolean] True if lock was successfully released, false otherwise
    def unlock(resource, token)
        # Step 1: Use a Lua script to safely release the lock
        # This ensures we only delete the key if it still contains our token
        unlock_script = <<-LUA
            if redis.call("get", KEYS[1]) == ARGV[1] then
                return redis.call("del", KEYS[1])
            else
                return 0
            end
        LUA

        # Step 2: Execute the script
        result = @client.eval(
            unlock_script,
            keys: [resource],  # KEYS[1] = lock key
            argv: [token]      # ARGV[1] = our token
        )

        # Step 3: Check result (1 = successfully deleted, 0 = key didn't exist or had different value)
        success = result == 1
        Rails.logger.debug "Redlock: #{success ? 'Successfully' : 'Failed to'} release lock for '#{resource}'"
        success
    end

    # Convenience method to execute a block with a distributed lock
    #
    # @param resource [String] The resource to lock
    # @param ttl_milliseconds [Integer] Lock TTL in milliseconds
    # @param retry_count [Integer] Number of retry attempts
    # @yield Block to execute while holding the lock
    # @return [Object] Result of the block if lock was acquired, nil otherwise
    def with_lock(resource, ttl_milliseconds: 10_000, retry_count: 3, &block)
        # Step 1: Attempt to acquire the lock
        token = lock(resource, ttl_milliseconds: ttl_milliseconds, retry_count: retry_count)
        return nil unless token  # Failed to acquire lock

        begin
            # Step 2: Execute the block while holding the lock
            Rails.logger.debug "Redlock: Executing block with lock for '#{resource}'"

            # &block captures the code block passed to with_lock
            # similar to Lambda Expression in C#
            result = yield

            # Step 3: Return the result
            result
        ensure
            # Step 4: Always release the lock, even if block raises an exception
            unlock(resource, token)
        end
    end

    # ======================================================================
    # Redlock Helper Methods
    # ======================================================================

    private

    # Generates a unique token for lock operations
    # Uses a combination of random data and timestamp for uniqueness
    def generate_lock_token
        # Use SecureRandom for cryptographically secure random data
        random_part = SecureRandom.hex(16)  # 32 hex characters
        timestamp_part = current_time_milliseconds.to_s

        # Combine and hash for a consistent length token
        Digest::SHA256.hexdigest("#{random_part}:#{timestamp_part}:#{object_id}")
    end

    # Gets the current time in milliseconds (required by Redlock algorithm)
    def current_time_milliseconds
        (Time.now.to_f * 1000).to_i
    end

    # constructor
    private
    def initialize()
        @client = Redis.new(url: AppSettings.redis_url)
    end
end
