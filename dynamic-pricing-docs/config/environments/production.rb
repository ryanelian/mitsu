require "active_support/core_ext/integer/time" # Loads ActiveSupport extensions so Integer gets time helpers like 1.hour, 2.days, etc.

# This file configures the Rails "production" environment.
# Think of Rails environments like ASP.NET's environment-specific appsettings (Development/Staging/Production).
# Values here take precedence over those in config/application.rb for this environment.
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In production, code is not reloaded between HTTP requests (no hot-reload).
  # Similar to disabling ASP.NET Core's developer hot reload. Improves performance and consistency.
  config.enable_reloading = false

  # Eager-load the application on boot.
  # This preloads most of the app into memory so:
  # - Threaded servers have classes ready without autoload overhead,
  # - Copy-on-write friendly for memory efficiency with prefork servers.
  # Rake tasks ignore this for performance.
  config.eager_load = true

  # Hide full error reports from end users and enable caching.
  # In ASP.NET terms, this is like not showing detailed exception pages in Production.
  config.consider_all_requests_local = false

  # Ensures that a master key has been made available in ENV["RAILS_MASTER_KEY"], config/master.key, or an environment
  # key such as config/credentials/production.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from `public/`, relying on NGINX/Apache to do so instead.
  # Typically you let your reverse proxy or CDN handle static assets for performance.
  # config.public_file_server.enabled = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # Example: point to a CDN host for assets.
  # config.asset_host = "http://assets.example.com"

  # Specifies the header that your server uses for sending files.
  # Use X-Sendfile (Apache) or X-Accel-Redirect (NGINX) to offload file transfer to the web server.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Mount Action Cable outside main process or domain.
  # Useful when hosting websockets separately or on a different subdomain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  # Can be used together with config.force_ssl for Strict-Transport-Security and secure cookies.
  # config.assume_ssl = true

  # Enforce HTTPS for all requests. This also sets HSTS and marks cookies as secure.
  # Comparable to UseHsts() + RequireHttpsAttribute in ASP.NET Core.
  config.force_ssl = true

  # Configure logging to STDOUT, which is container/12-factor friendly.
  # The chaining uses Ruby's tap/then:
  # - tap yields the current object (logger) to the block for side effects (set formatter) and returns it unchanged.
  # - then receives the previous result and returns the result of the block (wrap with TaggedLogging).
  # This reads like a pipeline, similar to fluent configuration patterns in C#.
  config.logger = ActiveSupport::Logger.new(STDOUT) # STDOUT is a global IO for standard output.
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new } # Set a simple, built-in Ruby logger formatter.
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }   # Wrap logger to support tag prefixes in logs.

  # Prepend all log lines with the following tags (e.g., request_id).
  # In ASP.NET, similar to including correlation IDs in logs via middleware.
  config.log_tags = [ :request_id ]

  # Set log level from environment; default to "info".
  # ENV.fetch reads process environment variables (strings). Rails accepts a string here.
  # "debug" is very verbose; "info" is a production-friendly default to avoid PII leakage.
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Use a different cache store in production.
  # For example, :mem_cache_store or :redis_cache_store in a real deployment.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (Rails' background job abstraction).
  # Similar to using Hangfire/Azure Queues in .NET. You can select adapter and queues per environment.
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "interview_production"

  # Enable I18n locale fallbacks. If a translation is missing for the current locale,
  # Rails will fall back to I18n.default_locale instead of raising or showing the key.
  config.i18n.fallbacks = true

  # Suppress deprecation logging in production to keep logs clean.
  config.active_support.report_deprecations = false

  # Don't dump the database schema after running migrations in production.
  # This avoids writing db/schema.rb on deploys where the app may not have write permissions.
  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection and other `Host` header attacks by whitelisting allowed hosts.
  # In production, you typically set this to your domain(s) and subdomains.
  # config.hosts = [
  #   "example.com",     # Allow requests from example.com
  #   /.*\.example\.com/ # Allow requests from subdomains like `www.example.com`
  # ]
  # Skip DNS rebinding protection for the default health check endpoint.
  # You can exclude a path (like "/up") from host authorization checks.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end