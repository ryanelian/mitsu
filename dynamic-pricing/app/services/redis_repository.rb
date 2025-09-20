# frozen_string_literal: true

require "redis"

# A singleton for accessing the Redis key-value store, implementing the repository pattern
class RedisRepository
    # gets the singleton instance
    def self.instance()
        @instance ||= new()
    end

    # private constructor
    private_class_method :new

    # Ping the Redis server
    def ping()
        @client.ping();
    end

    # constructor
    private
    def initialize()
        @client = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"))
    end
end
