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

  # Enable sending logs to Sentry
  config.enable_logs = true
  # Patch Ruby logger to forward logs
  config.enabled_patches = [:logger]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for tracing.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end