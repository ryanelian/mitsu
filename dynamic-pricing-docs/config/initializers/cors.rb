# Be sure to restart your server when you modify this file.
# In Rails, files under config/initializers are evaluated once at boot (for each process).
# This is similar to ASP.NET Core Program.cs/Startup.cs where you configure middleware at startup.
# Changes here won’t take effect until the server restarts (like changing middleware in Configure()).

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.
# CORS lets a browser call your API from a different origin (scheme+host+port).
# If you’ve configured CORS in ASP.NET Core with app.UseCors(...) and AddCors(...),
# this file serves the same purpose in Rails.

# Read more: https://github.com/cyu/rack-cors
# The rack-cors gem is a Rack (Ruby web server interface, analogous to ASP.NET Core middleware pipeline) middleware.
# Rails builds on Rack, so we insert this middleware into Rails’ middleware stack.

# HOW TO ENABLE:
# - Uncomment the block below to enable CORS.
# - Customize `origins` (who can call) and `resource` (what paths/headers/methods are allowed).
# - Keep it near the top of the stack so preflight OPTIONS requests are handled before other middleware.

# Rails.application.config.middleware.insert_before 0, Rack::Cors do  # insert_before 0 = put at the very front of the middleware stack (index 0).
#   allow do                                                           # Defines a policy block; you can have multiple `allow` blocks for different origins.
#     origins "example.com"                                            # Allowed origins. Can be String, Array, or Regexp. Equivalent to builder.WithOrigins(...).
#
#     resource "*",                                                    # Path pattern this rule applies to. "*" = all paths. Similar to allowing any endpoint.
#       headers: :any,                                                 # Allow any request headers. Symbol :any is a Ruby symbol (like enum value).
#       methods: [:get, :post, :put, :patch, :delete, :options, :head] # Allowed HTTP verbs. Ruby array of symbols. Includes OPTIONS for preflight and HEAD.
#   end
# end

# RUBY/RAILS NOTES FOR C#/TS DEVELOPERS:
# - Symbols (e.g., :get) are immutable identifiers in Ruby, often used where enums/strings might be used in C#.
# - Arrays use [ ... ] like JavaScript/TypeScript.
# - This config is declarative; rack-cors will translate it into proper CORS response headers.

# COMMON CUSTOMIZATIONS (EXAMPLES ONLY—LEAVE COMMENTED):
#
# 1) Allow multiple origins (e.g., local dev + deployed frontend):
#
# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "http://localhost:3000", "https://app.example.com" # Array of allowed origins. You can also use ENV variables.
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end
#
# 2) Configure via environment variables (safe for different environments):
#
# # FRONTEND_ORIGINS can be a comma-separated list, e.g., "http://localhost:3000,https://app.example.com"
# origins_list = (ENV["FRONTEND_ORIGINS"] || "").split(",").map(&:strip).reject(&:empty?)  # Ruby idiom: split string to array; map(&:strip) trims; reject removes empties.
# # Rails.application.config.middleware.insert_before 0, Rack::Cors do
# #   allow do
# #     origins(*origins_list) # splat (*) passes array elements as arguments, similar to params array in C#.
# #     resource "*", headers: :any, methods: [:get, :post, :put, :patch, :delete, :options, :head]
# #   end
# # end
#
# 3) Allow credentials (cookies/Authorization) and expose custom headers:
#
# # Rails.application.config.middleware.insert_before 0, Rack::Cors do
# #   allow do
# #     origins "https://app.example.com"
# #     resource "*",
# #       headers: :any,
# #       methods: [:get, :post, :put, :patch, :delete, :options, :head],
# #       credentials: true,               # Like AllowCredentials in ASP.NET Core CORS; permits cookies/Authorization to be sent.
# #       expose: ["X-Request-Id"]         # Headers the browser can read from the response beyond the CORS safelist.
# #   end
# # end
#
# 4) Restrict to specific paths and tune caching (preflight max_age):
#
# # Rails.application.config.middleware.insert_before 0, Rack::Cors do
# #   allow do
# #     origins "https://app.example.com"
# #     resource "/api/*",                 # Only apply to /api routes.
# #       headers: :any,
# #       methods: [:get, :post, :put, :patch, :delete, :options, :head],
# #       max_age: 600                     # Seconds the browser can cache the preflight (similar to SetPreflightMaxAge).
# #   end
# # end
#
# SECURITY TIPS:
# - Avoid "*" for origins in production, especially with credentials: true; most browsers block credentials with wildcard origins.
# - Always include :options in methods so preflight requests succeed.
# - Place this middleware at the top (insert_before 0) to ensure CORS headers are added before other middleware runs (like auth).
#
# TROUBLESHOOTING:
# - If your browser shows CORS errors, inspect the response headers for Access-Control-Allow-* and ensure they match your request.
# - Confirm the origin exactly matches (scheme, host, and port). "http://localhost:3000" != "https://localhost:3000".
# - Restart the Rails server after changing this file.