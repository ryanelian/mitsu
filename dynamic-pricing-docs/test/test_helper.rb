# -----------------------------------------------------------------------------
# Rails test bootstrap (Minitest)
# This file is automatically required by `bin/rails test` and sets up the
# testing environment for a Rails app that uses Minitest (Rails' default).
#
# Perspective for C#/TypeScript devs:
# - Think of this as the rough equivalent of a global test setup file that
#   configures ASP.NET Core's host for integration tests and xUnit/NUnit behavior,
#   or a Jest setup file for a React app.
# - Rails encourages convention over configuration; most of this is "magic"
#   wiring so your tests can focus on behavior, not bootstrapping.
# -----------------------------------------------------------------------------

# Set the process environment variable RAILS_ENV to "test" if it isn't already set.
# Ruby's `||=` is "assign if falsey" (nil or false). Similar to C#'s `??=` (null-coalescing
# assignment) but note: Ruby treats both nil and false as falsey.
ENV["RAILS_ENV"] ||= "test"  # Ensures the app boots in test mode (separate DB, configs, etc.)

# Load the Rails application environment for tests.
# `require_relative` loads a file relative to this file's directory (like C# relative path include).
# This boots the entire Rails app (models, DB connections, initializers) under the "test" env.
require_relative "../config/environment"  # Equivalent to building the host in ASP.NET test setup

# Pull in Rails' Minitest integration helpers.
# This wires up things like transactional tests, fixture loading, and Rails-specific assertions.
require "rails/test_help"  # Similar in spirit to adding xUnit extensions/helpers in .NET test projects

# -----------------------------------------------------------------------------
# Base test class for all Rails tests using Minitest.
# - ActiveSupport::TestCase is Rails' subclass of Minitest::Test that adds Rails sugar.
# - The `ActiveSupport` namespace (module) is referenced with `::` (like C# namespaces).
# - All test classes typically inherit from this to get fixtures, parallelization, etc.
# -----------------------------------------------------------------------------
class ActiveSupport::TestCase
  # Run tests in parallel with specified workers.
  # Rails can parallelize tests using threads or processes depending on config.
  # Setting workers: 1 effectively disables parallelism (useful to avoid flaky tests or DB contention).
  # In CI, you might increase this to the number of CPU cores to speed up runs.
  parallelize(workers: 1)  # Comparable to [CollectionBehavior(DisableTestParallelization = true)] in xUnit

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # Fixtures are YAML files that seed the test database with known records before tests run,
  # similar to seeding a test DB in integration tests. Rails auto-creates helper methods
  # to access them (e.g., `users(:admin)` yields the "admin" fixture row).
  # Note: Factories (e.g., FactoryBot) are an alternative, but this project uses fixtures.
  fixtures :all  # Loads every YAML file in test/fixtures into the test DB before each test

  # Add more helper methods to be used by all tests here...
  # Place shared assertion helpers or utility methods here, akin to a base test class in C#.
end