# ------------------------------------------------------------------------------
# config/environment.rb
#
# Purpose:
# - This is one of the smallest but most critical files in a Rails app: it boots
#   the application environment. Think of it like the ASP.NET Core Program.cs
#   entry point that builds and initializes the host (combined with parts of
#   Startup.cs in older templates).
#
# How it fits in the boot sequence:
# - bin/rails, rake tasks, the Rails console, the test runner, and the app server
#   all require this file to ensure the framework and your app are initialized.
# - This file depends on config/application.rb, which defines your Application
#   class (e.g., MyApp::Application) and the global Rails.application instance.
# - After loading application.rb, we call Rails.application.initialize! which:
#     * Loads environment-specific config (config/environments/*.rb)
#     * Runs all framework and app initializers (config/initializers/*.rb)
#     * Configures middleware, autoloaders (Zeitwerk), I18n, logger, etc.
#     * Prepares framework subsystems (ActiveRecord, ActiveJob, ActionController, …)
#   Rough analogy:
#     - config/application.rb ~ ASP.NET Host/Builder setup (services and global config)
#     - Rails.application.initialize! ~ Host.Build()/Run() + Startup.Configure(...)
#
# Ruby/Rails idioms to note:
# - require_relative "application" loads a Ruby file relative to this file’s path.
#   Similar to using a relative import in Node or referencing a file in C#, but
#   evaluated at runtime.
# - Rails.application is a globally accessible singleton-like object (a constant
#   referencing an Application instance), analogous to the ASP.NET IHost or the
#   top-level WebApplication in minimal hosting.
# - The bang (!) in initialize! follows a Ruby convention indicating a method
#   that performs an action with side effects or that can raise if misused
#   (e.g., calling it twice). You typically call it exactly once during boot.
# - No explicit "return" is needed; top-level Ruby code executes as the file is
#   required, and side effects (initialization) are what we want here.
# ------------------------------------------------------------------------------

# Load the Rails application by requiring config/application.rb relative to this file.
# - require_relative resolves the path relative to this file’s directory.
# - It is idempotent: if the file has already been required in this process, it
#   won’t be reloaded.
# - This sets up the Application class and prepares configuration but does NOT
#   fully boot the framework yet.
require_relative "application"  # -> loads config/application.rb (defines YourApp::Application and config)

# Initialize (boot) the Rails application.
# - This is where Rails wires everything together:
#   * Evaluates config/environments/#{Rails.env}.rb (development/test/production)
#   * Runs framework + app initializers in a well-defined order
#   * Finalizes middleware stack and autoloading
#   * Prepares subsystems; DB connections may be established lazily on first use
# - Comparable to building and starting the ASP.NET Core host (builder.Build();
#   app.Configure(...); app.Run();), though Rails keeps this API compact.
Rails.application.initialize!  # -> perform full boot; run initializers; ready the app for server/console/tasks