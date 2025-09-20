# This file defines the core configuration for your Rails application.
# If you're coming from ASP.NET Core, think of this as a combination of:
# - Program.cs (bootstrapping, selecting frameworks/middleware)
# - appsettings/environment-specific overrides (via config/environments/*)
# - Some conventions similar to how Next.js/TypeScript relies on opinionated defaults.
#
# Nothing here executes a server directly; it configures the app class that Rails uses
# when booting through bin/rails, rack servers, or background tasks.

require_relative "boot"  # Load config/boot.rb relative to this file. Similar to setting up the host builder in Program.cs; it prepares Bundler and environment.

require "rails"  # Core Rails loader. Pulls in the railties system (framework components). Comparable to referencing Microsoft.AspNetCore.* packages.

# Pick the frameworks you want:
require "active_model/railtie"      # Validation and serialization framework (like DataAnnotations + POCO validation in .NET).
require "active_job/railtie"        # Background job abstraction (similar to IHostedService abstractions; adapters for Sidekiq, etc.).
require "active_record/railtie"     # ORM (like Entity Framework Core) for database access and migrations.
# require "active_storage/engine"   # Disabled: file uploads/attachments management. Enable if you need blob storage-like features.
require "action_controller/railtie" # HTTP layer/controllers (like ASP.NET Core MVC without views when api_only = true).
# require "action_mailer/railtie"   # Disabled: email delivery framework.
# require "action_mailbox/engine"   # Disabled: inbound email routing to your app.
# require "action_text/engine"      # Disabled: rich text content via Trix; integrates with Active Storage.
require "action_view/railtie"       # View rendering (ERB templates). Even in API-only apps, some rendering internals are used by controllers.
require "action_cable/engine"       # WebSockets (like SignalR conceptually).
# require "rails/test_unit/railtie" # Disabled: built-in test framework; many projects use RSpec instead.

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
# Bundler groups are like configuration groups (e.g., different ItemGroups or conditional PackageReferences).
Bundler.require(*Rails.groups)  # Loads gems for the current environment. Rails.groups returns [:default, Rails.env, ...].

module Interview  # Top-level namespace for the app (like a root C# namespace).
  # The Rails application class. Inherits framework behavior and exposes the `config` object.
  # In ASP.NET Core, this is analogous to the WebApplicationBuilder + services/configure pipeline.
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # This sets baseline behavior toggles introduced in Rails 7.1 (e.g., Zeitwerk settings, security defaults).
    # Similar to setting a compatibility version in ASP.NET Core.
    config.load_defaults 7.1

    # Configure autoloading under app/lib (and siblings) using Zeitwerk (Ruby's code loader in Rails).
    # This tells Rails to ignore certain subdirectories within lib/ that aren't Ruby code,
    # preventing the loader from trying to treat assets/tasks as Ruby constants.
    # Parallels: excluding folders from compilation in a .csproj or tsconfig's "exclude".
    #
    # Note:
    # - "assets" might contain static files, templates, etc.
    # - "tasks" often contains Rake tasks (.rake) rather than .rb files.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # Example of explicit timezone configuration:
    # config.time_zone = "Central Time (US & Canada)"  # Similar to CultureInfo/time zone defaults in .NET.
    # Example of adding eager load paths (folders to preload in production):
    # config.eager_load_paths << Rails.root.join("extras")  # Like specifying assemblies/types to load at startup.

    # Only loads a smaller set of middleware suitable for API only apps.
    # - Disables sessions, cookies, flash by default (can be added back manually).
    # - Skips view helpers/assets when generating scaffolds.
    # This roughly matches an ASP.NET Core "Minimal API" or AddControllers() without Razor Views.
    # You can still enable specific middleware as needed via config or application stack.
    config.api_only = true
  end
end