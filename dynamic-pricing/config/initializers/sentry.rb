# frozen_string_literal: true

Sentry.init do |config|
  dsn = ENV["SENTRY_DSN"]
  # If no DSN, fail safely. Do NOT crash the app.
  if dsn.nil? || dsn.empty?
    Rails.logger.warn "SENTRY_DSN is not set. Sentry will not be initialized."
    return
  end

  config.dsn = dsn
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true

  # Disable sending all logs to Sentry to reduce noise
  config.enable_logs = false
  # Don't patch logger to avoid forwarding all logs
  # config.enabled_patches = [:logger]
  config.enabled_patches = []

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for tracing.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 0
end