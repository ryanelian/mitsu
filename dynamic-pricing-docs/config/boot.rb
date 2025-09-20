# This file runs very early in the Rails boot process.
# Think of it like the minimal bootstrap that prepares dependency loading
# before the framework and your app code run—similar in spirit to early
# startup/bootstrap in ASP.NET Core (e.g., Program.cs) or Next.js runtime setup.
# It sets a key environment variable and then requires two small bootstrapping
# helpers:
# - bundler/setup: tells Ruby how to load gems declared in the Gemfile (akin to
#   NuGet package resolution or npm/yarn/pnpm dependencies)
# - bootsnap/setup: a performance helper that caches expensive operations to
#   speed up application boot (especially useful in development)

# Configure the path to the Gemfile for Bundler by setting ENV["BUNDLE_GEMFILE"].
# - ENV in Ruby is a Hash-like interface over the OS environment variables
#   (similar to Environment.GetEnvironmentVariable in C#, or process.env in Node).
# - The ||= operator means "assign only if the current value is nil or false".
#   Note: it does NOT treat empty string "" as falsey (unlike some JS idioms).
# - File.expand_path("../Gemfile", __dir__) resolves an absolute path to
#   the Gemfile located one directory above this file (config/ -> project root).
#   __dir__ is the directory of the current file (like AppContext.BaseDirectory,
#   combined with Path APIs, in .NET).
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__) # Default Gemfile path unless already provided externally.

# Load Bundler's setup so that 'require' can find gems listed in the Gemfile.
# - This configures Ruby's "load path" ($LOAD_PATH) to include the right gem
#   versions resolved by Bundler (analogous to NuGet restoring/choosing the
#   correct versions and making them available).
# - 'require' in Ruby loads a library by name once per process; subsequent calls
#   are no-ops because the feature is tracked in $LOADED_FEATURES.
require "bundler/setup" # Set up gems listed in the Gemfile. Ensures requires resolve to the locked gem versions.

# Enable Bootsnap to cache expensive operations and reduce boot time.
# - Bootsnap accelerates common tasks like require path lookups and YAML parsing
#   by writing cache files to disk (safe to delete; they'll be regenerated).
# - Particularly helpful in development/test; harmless in production.
# - This requires comes after bundler/setup in the default Rails template; keep order unchanged.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.