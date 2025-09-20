# This file configures Rails behavior specifically for the "development" environment.
# If you're coming from ASP.NET Core, think of environment-scoped settings like appsettings.Development.json
# combined with code in Program.cs/Startup.cs that wires middleware and services for Development.
# Rails loads this file only when RAILS_ENV=development.
#
# Note on Ruby/Rails idioms you'll see:
# - Symbols like :log or :raise are lightweight identifiers (similar to enums/atoms).
# - Methods without parentheses are common if arguments are clear (pure syntax sugar).
# - "2.days" is provided by Active Support to express durations; it returns an ActiveSupport::Duration.
# - Settings are applied via the config object inside Rails.application.configure do ... end.

# Pull in Active Support extensions so Integer gains time helpers like 2.days, 1.hour, etc.      # e.g., used below in Cache-Control header
require "active_support/core_ext/integer/time"

# Open a configuration block scoped to the Rails application instance.                           # Equivalent to configuring services/middleware for Development in ASP.NET Core
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.             # Environment overrides base application config

  # In development, Rails reloads application code on every request when it changes.              # Like ASP.NET Core hot reload; trades performance for no-restart edits
  # This is slower but avoids restarting the server after code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.                                                              # Avoid loading entire app on startup for faster boot and lower mem while developing
  config.eager_load = false

  # Show full error reports to the browser.                                                      # Similar to ASP.NET Core DeveloperExceptionPage
  config.consider_all_requests_local = true

  # Enable Server-Timing headers for performance diagnostics in the browser DevTools.             # Adds Server-Timing response headers
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.                                       # Dev typically disables caching to see changes immediately
  # Run rails dev:cache to toggle caching.                                                        # This task creates/deletes tmp/caching-dev.txt as the switch
  if Rails.root.join("tmp/caching-dev.txt").exist?                                               # Check for the toggle file relative to app root
    # Use in-memory cache store when caching is enabled.                                          # Comparable to MemoryCache in .NET
    config.cache_store = :memory_store
    # Set Cache-Control headers for static files served by Rails (not via a separate web server). # public means cacheable by any cache; max-age in seconds
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"                                        # 2.days (duration) -> seconds integer via to_i
    }
  else
    # Explicitly disable controller-level caching paths.                                          # Ensures no read/write caching happens
    config.action_controller.perform_caching = false

    # Use a null store so cache operations are no-ops.                                            # Like a black-hole cache implementation
    config.cache_store = :null_store
  end

  # Print deprecation notices to the Rails logger.                                                # Logs deprecation warnings instead of raising
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.                                                 # If a message matches the disallowed list below, raise instead of logging
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.                                   # Array of string patterns; empty means none disallowed
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.                                  # Similar to running EF Core migrations check at startup; fails fast in dev
  config.active_record.migration_error = :page_load

  # Highlight in logs the exact source lines that triggered database queries.                      # Very handy when scanning logs; shows call sites
  config.active_record.verbose_query_logs = true

  # Highlight in logs where background jobs were enqueued from.                                    # Shows call sites for job enqueues (Active Job adapters like Sidekiq)
  config.active_job.verbose_enqueue_logs = true


  # Raises error for missing translations.                                                         # Uncomment to fail fast when i18n keys are missing (useful in dev)
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.                                                        # Uncomment to append view file paths as HTML comments for easier debugging
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.                            # Disables CSRF protection for websockets in dev; use with caution
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions               # Helps catch typos/misconfig in controller callbacks (like filters in ASP.NET)
  config.action_controller.raise_on_missing_callback_actions = true
end