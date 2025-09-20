# frozen_string_literal: true
#------------------------------------------------------------------------------
# Rails environment configuration for the "test" environment.
#
# Rough analogy to C#/ASP.NET Core:
# - Think of this file like appsettings.Test.json + Startup/Program conditionals.
# - Rails has three primary environments by convention: development, test, production.
#   This file tweaks framework behavior specifically when Rails.env == "test".
#
# Key ideas for a C#/TypeScript engineer:
# - Rails.application.configure do ... end yields a mutable config object. Settings
#   placed inside override defaults defined in config/application.rb (akin to
#   overriding AddControllers options or middleware in a test profile).
# - Most keys here affect Rails framework subsystems (Action Controller, Active Support,
#   Action Dispatch) similar to how you configure MVC, logging, exception handling, etc.
# - Everything here is evaluated at boot of the test process (e.g., when running `rails test`
#   or an RSpec suite).
#------------------------------------------------------------------------------

require "active_support/core_ext/integer/time"  # Brings Integer time helpers like 1.hour, 30.seconds, returning ActiveSupport::Duration

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do  # Begin environment-specific configuration block

  # Settings specified here will take precedence over those in config/application.rb.
  # Similar to ASP.NET: environment-specific overrides take precedence over defaults.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false  # In tests, we don't need the dev-style code reloader; reduces nondeterminism

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?  # Eager-load app code only on CI. present? is an ActiveSupport helper (nil/blank-string safe truthiness)

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true  # Serve static files during tests (akin to UseStaticFiles in ASP.NET)
  config.public_file_server.headers = {     # Set headers for served static assets
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"  # max-age expects seconds; 1.hour.to_i converts duration to seconds (3600)
  }  # Hash literal of headers; only Cache-Control is set here

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true  # Always show detailed errors (like ASP.NET DeveloperExceptionPage)
  config.action_controller.perform_caching = false  # Disable controller-level caching to keep tests deterministic
  config.cache_store = :null_store  # No-op cache adapter; all cache reads miss, writes are ignored

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable  # Rails will render error responses for known/rescuable exceptions; others raise to fail fast

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false  # Turns off CSRF verification to simplify posting in tests (similar to disabling Antiforgery)

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr  # Direct deprecation warnings to standard error (useful for CI logs)

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise  # If a deprecation matches the list below, raise instead of warn

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []  # Add exact message strings or regexes to escalate specific deprecations

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true  # Enable to fail tests when I18n keys are missing (helpful for localization discipline)

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true  # Adds HTML comments with view partial paths; useful when debugging views

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true  # Helps catch typos like before_action :foo, only: :bar when :bar action doesn't exist
end  # End environment-specific configuration block