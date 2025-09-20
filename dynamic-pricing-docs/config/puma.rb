# This configuration file is executed by Puma (the Ruby/Rails HTTP server) at process boot.
# Unlike C# where you'd configure Kestrel through strongly-typed objects in Program.cs,
# Puma uses a DSL (Domain-Specific Language) of top-level method calls (e.g., `threads`, `port`).
# These methods are provided by Puma and are evaluated in Puma's configuration context.

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method takes two arguments: minimum and maximum thread counts.
# In C# terms, think of this as configuring the server's thread pool for handling requests
# (though the underlying models differ). Active Record (Rails' ORM) also has a default pool size of 5.
# ENV in Ruby exposes environment variables as strings (similar to Environment.GetEnvironmentVariable in .NET).
# ENV.fetch("NAME") will raise if missing; providing a block `{ default }` supplies a fallback.
# Using a block defers evaluation (minor perf) and mirrors the Ruby style for defaults.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }        # String from ENV or default 5; Ruby will coerce to Integer when needed by Puma
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count } # Default min = max, i.e., a fixed-size pool unless overridden
threads min_threads_count, max_threads_count                    # Puma DSL: set thread pool bounds

# Capture Rails environment once to avoid repeated ENV lookups and to keep a single source of truth below.
# Typical values: "development", "test", "production" (all lowercase strings).
rails_env = ENV.fetch("RAILS_ENV") { "development" }            # Equivalent to ENV["RAILS_ENV"] || "development"

# Worker processes:
# - In Puma, "workers" = OS processes (pre-fork model), "threads" = in-process threads.
# - In C# hosting terms, "workers" are closer to separate processes (like multiple IIS worker processes),
#   while "threads" are similar to Kestrel thread handling within a single process.
# - Multi-process can leverage multiple CPU cores and isolate GIL effects in MRI Ruby.
if rails_env == "production"                                    # Only enable multi-process logic in production
  # WEB_CONCURRENCY should be set to the number of CPU cores for best throughput when using threads.
  # ENV variables are strings; Integer(...) converts and raises if invalid (like int.Parse in C#).
  worker_count = Integer(ENV.fetch("WEB_CONCURRENCY") { 1 })    # Default to 1 worker if not provided
  if worker_count > 1
    workers worker_count                                        # Puma DSL: spawn N worker processes (cluster mode)
  else
    preload_app!                                                # Load app code before forking; with a single worker this simply loads early
  end
end

# Configure how long (in seconds) Puma waits before terminating an idle worker in development.
# Note: This line intentionally re-fetches ENV directly rather than using rails_env variable above.
# The behavior is identical here, but this demonstrates two common patterns you'll see in configs.
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"  # Long timeout for convenient debugging

# Bind port for HTTP requests. Defaults to 3000 (Rails convention), like Kestrel default 5000/5001.
# Many platforms (Heroku, container orchestrators) inject PORT via ENV; we honor that here.
port ENV.fetch("PORT") { 3000 }                                  # Puma DSL: listen on this port

# Set the Rack/Rails environment for Puma to run under (influences logging, middleware, caching, etc.).
environment rails_env                                            # Puma DSL: set environment

# PID file location for the running Puma master process.
# Useful for process managers or tooling that need to signal the server.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }           # Rails convention: tmp/pids/

# Allow `bin/rails restart` (or `rails restart`) to signal Puma to restart itself.
# This integrates with Rails' dev workflow similarly to dotnet watch, but via a plugin hook.
plugin :tmp_restart                                              # Puma DSL: enable tmp_restart plugin