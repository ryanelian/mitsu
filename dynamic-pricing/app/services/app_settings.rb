# frozen_string_literal: true

# A strongly-typed module for accessing environment variables safely
# It will log an error and throw an error if the environment variable is not set
module AppSettings
    module_function

    def redis_url
        require_env!("REDIS_URL")
    end

    def rate_api_url
        require_env!("RATE_API_URL")
    end

    def rate_api_token
        require_env!("RATE_API_TOKEN")
    end

    def rate_api_quota
        quota = require_env!("RATE_API_QUOTA")
        quota.to_i
    end

    # Reads env var, logs error if missing/blank, then raises
    def require_env!(key)
        value = ENV[key]
        if value.nil? || value.strip.empty?
            Rails.logger.error("Missing required environment variable: #{key}")
            raise "Missing required environment variable: #{key}"
        end
        value
    end
end
