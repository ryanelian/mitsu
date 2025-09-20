# Be sure to restart your server when you modify this file.
# In Rails, files under config/initializers run once at application boot (similar to ASP.NET Core's Program.cs/Startup.cs Configure).
# That means changes here won't take effect in a running process until you restart your server (or reload in development).

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
#
# What this does (high level):
# - Rails uses ActiveSupport::ParameterFilter to scrub sensitive values from logs.
# - Any incoming parameters (query string, form data, JSON body), as well as nested structures (hashes/arrays),
#   will have matching keys' values replaced with "[FILTERED]" before being logged.
# - This protects secrets from appearing in development/production logs, akin to redaction in ASP.NET Core logging middleware.
#
# Matching rules (practical notes for a C#/TypeScript dev):
# - Entries in this array can be Symbols, Strings, or Regexps. Here we use Symbols (e.g., :passw).
# - String/Symbol filters perform a partial, case-insensitive match against parameter keys.
#   Example: :passw will match "password", "user_password", "passw_confirmation", etc.
# - Regexps allow precise control if needed (not used here).
#
# Behavior details:
# - Only affects logging and similar inspection (e.g., request.filtered_parameters). It does NOT alter actual request data,
#   database persistence, or validation—just what is written to logs.
# - Applies deeply (nested parameters are also filtered) and is used by various Rails components when serializing params/events for logs.
# - Using += appends to any existing filters. In Ruby, += creates a new Array (left + right) and assigns it back to the attribute.
#   This preserves any default filters Rails may have set earlier.
#
# Guidance:
# - Keep filters specific to avoid over-filtering useful diagnostics (e.g., do not filter generic keys like :id).
# - If you need to target exact names only, consider using Regexps (e.g., /\Apassword\z/i), but only if necessary.
Rails.application.config.filter_parameters += [
  :passw,       # Partial match for "password", "password_confirmation", etc.
  :secret,      # Matches keys like "secret", "client_secret", "session_secret"
  :token,       # Matches "token", "auth_token", "access_token", "csrf_token"
  :_key,        # Matches anything ending/containing "_key" like "api_key", "private_key"
  :crypt,       # Matches "crypt", "encrypted_*" (e.g., "encrypted_password")
  :salt,        # Matches "salt", "password_salt"
  :certificate, # Matches "certificate", "client_certificate", "ssl_certificate"
  :otp,         # Matches "otp", "otp_code", "one_time_password"
  :ssn          # Matches "ssn", "social_security_number"
]