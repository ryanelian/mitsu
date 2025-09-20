# db/seeds.rb — Seed data for all environments
#
# This file is the Rails equivalent of application/database seeders you might write in:
# - ASP.NET Core: a "SeedData.Initialize" method invoked at startup or within an EF Core migration.
# - TypeScript/Node: a seed script run via a package script using an ORM (e.g., Prisma seed.ts).
#
# Key points:
# - Executed with: bin/rails db:seed (runs in the current RAILS_ENV; defaults to development).
# - Also runs automatically with: bin/rails db:setup (creates DB, loads schema, then runs seeds).
# - Should be idempotent: Running multiple times should not duplicate data or crash.
#   Use "find_or_create_by!" / "create_or_find_by" / "upsert_all" patterns instead of "destroy_all + create".
# - Runs inside your Rails app context, so you can reference models directly (e.g., User, Post).
#
# Ruby/Rails idioms to know (C#/TypeScript parallels in comments below):
# - Symbols (:name) are lightweight, interned identifiers, often used as Hash keys (similar to enums/constant keys).
# - Hash literal with symbol keys: { name: "Action" } (Ruby 1.9+), like new { name = "Action" } in C# anonymous type,
#   or { name: "Action" } in TS (but Ruby uses symbols rather than strings for keys by convention).
# - Bang methods (method_name!) raise exceptions on failure; non-bang versions typically return false/nil instead.
# - Blocks "do ... end" are like lambdas/anonymous delegates in C# or callbacks in JS, passed implicitly to methods.
# - Active Record models map to tables; methods like find_or_create_by! hit the database.
#
# Idempotency strategies (choose the one that fits your constraints):
# - find_or_create_by!(unique_attributes_hash)           # Reads first; creates if not found (1 row).
# - create_or_find_by(unique_attributes_hash)            # Tries insert first; if unique index hits, reads existing.
# - upsert_all(array_of_rows, unique_by: :index_name)    # Bulk upsert (no callbacks/validations), Rails 6+.
# - update_or_create-like: model.find_or_initialize_by(...).update!(...)  # "Upsert" with validations/callbacks.
#
# Environment-specific seeding:
# - You can guard by Rails.env.development? (like ASPNETCORE_ENVIRONMENT == "Development") to add sample data
#   only for development/test, and keep production seeds minimal and safe.
#
# Transactions:
# - You can wrap seeds in ApplicationRecord.transaction { ... } so that failures roll back partial inserts.
#
# Error handling:
# - Prefer bang methods (create!/update!/find_or_create_by!) in seeds so the process fails fast and loudly on invalid data.
#
# Performance:
# - For large static datasets, prefer upsert_all or import methods over N inserts in a loop.
#
# Security:
# - Do not hardcode real credentials. Use ENV["ADMIN_PASSWORD"] etc. for secrets you must seed.
#
# Sample commands you might run:
# - bin/rails db:seed       # Seed current environment.
# - RAILS_ENV=production bin/rails db:seed  # Seed production.
# - bin/rails db:setup      # Create DB, load schema, run seeds from scratch.
#
# The template example below demonstrates an idempotent pattern in Ruby using a block.
# Its runtime behavior is commented out to keep this file a no-op by default.

# Example (simple, idempotent creation of reference data):
#
#   # Array literal with strings; "each" yields each element to the block variable "genre_name".         # Ruby: enumerable iteration
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|                                        # C#/TS analog: ["Action", ...].forEach(genreName => { ... })
#     # Finds by "name"; if not found, creates a new record and saves it; raises on validation failure.  # Prefer bang-methods in seeds
#     MovieGenre.find_or_create_by!(name: genre_name)                                                   # Unique constraint on name recommended to enforce idempotency
#   end

# Example (create-or-find pattern that prefers insert first, then read on unique violation):
#
#   ["USD", "EUR", "JPY"].each do |code|                                                                # Loop through ISO currency codes
#     Currency.create_or_find_by(code: code)                                                            # Uses DB unique index to handle races gracefully
#   end

# Example (find-or-initialize + update, useful when you want to ensure attributes are set/overwritten):
#
#   admin = User.find_or_initialize_by(email: "admin@example.com")                                      # Find existing row or build an unsaved instance
#   admin.assign_attributes(                                                                            # Set attributes in-memory (does not save yet)
#     name: "System Administrator",                                                                     # Symbol-keyed hash for attributes
#     role: "admin"                                                                                     # Could be enum-backed in Rails
#   )
#   admin.password = ENV.fetch("ADMIN_PASSWORD", "change-me")                                           # Use env var with a default for dev
#   admin.save!                                                                                         # Persist and raise if invalid

# Example (environment-guarded seeds; only executes in development):
#
#   if Rails.env.development?                                                                           # Similar to if (env.IsDevelopment()) in ASP.NET Core
#     puts "[seeds] Creating development-only sample data..."                                           # STDOUT logging is fine in seeds
#     10.times do |i|                                                                                   # 0..9; times yields the index
#       Post.find_or_create_by!(title: "Sample Post #{i + 1}") do |post|                                # Block yields the new record before save
#         post.body = "Lorem ipsum..."                                                                  # Set additional fields for new records
#       end
#     end
#   end

# Example (wrapping seeds in a transaction for atomicity):
#
#   ApplicationRecord.transaction do                                                                     # Rolls back all changes if an exception occurs
#     FeatureFlag.create_or_find_by!(key: "payments_enabled")                                            # Seed a feature toggle
#     FeatureFlag.create_or_find_by!(key: "beta_onboarding")                                             # Seed another toggle
#   end

# Example (bulk upsert for performance; no validations/callbacks are run):
#
#   countries = [
#     { code: "US", name: "United States" },
#     { code: "CA", name: "Canada" },
#     { code: "MX", name: "Mexico" }
#   ]
#   Country.upsert_all(countries, unique_by: :index_countries_on_code)                                   # Requires a unique index on "code"

# Example (loading per-environment seed files, if you choose to organize that way):
#
#   # db/seeds/development.rb, db/seeds/test.rb, db/seeds/production.rb                                 # Create these files as needed
#   env_seed = Rails.root.join("db", "seeds", "#{Rails.env}.rb")                                        # Build a path based on current environment
#   load env_seed if File.exist?(env_seed)                                                               # Conditionally load the file

# Example (handling referential integrity and ordering):
#
#   # If you must seed in an order (e.g., parent before child), keep it explicit and minimal.
#   # For PostgreSQL, you can temporarily disable FK checks using a connection helper:
#   # ActiveRecord::Base.connection.disable_referential_integrity do
#   #   # Seed parent tables first, then children
#   # end

# Tips for Ruby syntax if you're coming from C#/TypeScript:
# - No semicolons needed; line breaks terminate statements.
# - String interpolation uses "#{expr}" inside double-quoted strings.
# - Blocks: method(arg) { |x| ... } or do |x| ... end (multi-line). "yield" passes control to the block.
# - Constants are all-caps by convention (e.g., DEFAULT_EMAIL); classes/modules are CamelCase; methods/variables are snake_case.
# - Exceptions: raise "message" (equiv. throw new Exception("message")), rescue => e (equiv. catch in C#).
#
# Keep this file safe to run in production. Favor small, necessary reference data for prod,
# and guard large sample datasets behind Rails.env.development? or Rails.env.test?.
#
# By default, this template seeds nothing. Uncomment and adapt one of the examples above to start.