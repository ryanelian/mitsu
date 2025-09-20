# Executive Summary
- File: config/environments/development.rb
- TL;DR: Development-only Rails configuration enabling code reloading, verbose error/logging, optional in-memory caching via a toggle file, and stricter checks (e.g., migration errors). It shapes how the app behaves during local development, akin to ASP.NET Core’s Development environment settings.

# Ruby Concepts
| Ruby Concept | What It Is | C#/TS Analogy |
| --- | --- | --- |
| require "active_support/core_ext/integer/time" | Extends Integer with time helpers (e.g., 2.days) | C# extension methods + TimeSpan.FromDays(2) |
| Symbols (e.g., :memory_store) | Lightweight identifiers used as config values | C# enums or named constants |
| Hash literals with => | Key-value maps, older hash rocket syntax | Dictionary<string, object> initialization |
| Blocks (do ... end) | Anonymous functions/closures passed to methods | C# lambdas/Action delegates |
| String interpolation "#{...}" | Embed expressions into strings | C# string interpolation $"{...}" |
| Predicate methods (exist?) | Methods ending with ? return boolean | C# methods returning bool, naming convention like Exists |

# Rails Concepts
| Rails Concept | What It Is | ASP.NET/React Analogy |
| --- | --- | --- |
| Rails.application.configure | Environment-specific configuration block | ConfigureServices/Configure in Startup for Development |
| config.enable_reloading | Reload app code on change in dev | dotnet watch / Hot Reload |
| config.eager_load | Preload app code on boot (disabled here) | Preloading assemblies or disabling for faster dev start |
| config.cache_store | Chooses cache backend (memory/null) | IDistributedCache / IMemoryCache selection |
| config.consider_all_requests_local | Show full error pages in dev | Developer Exception Page |
| config.active_record.migration_error = :page_load | Raise error if migrations pending | Fail fast if EF Core migrations not applied (custom middleware) |

# Code Anatomy
- Rails.application.configure do ... end: Opens the development environment configuration block.
- config.enable_reloading = true: Automatic code reload on file changes.
- config.eager_load = false: Do not preload app code in dev.
- config.consider_all_requests_local = true: Show detailed error reports.
- config.server_timing = true: Emit Server-Timing headers.
- if Rails.root.join("tmp/caching-dev.txt").exist?: Toggle caching based on marker file presence.
  - config.cache_store = :memory_store: Use in-memory cache when enabled.
  - config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{2.days.to_i}" }: Set static asset cache headers.
- else branch:
  - config.action_controller.perform_caching = false: Disable controller-level caching.
  - config.cache_store = :null_store: No-op cache.
- config.active_support.deprecation = :log: Log deprecation warnings.
- config.active_support.disallowed_deprecation = :raise: Raise on disallowed deprecations.
- config.active_support.disallowed_deprecation_warnings = []: None disallowed explicitly.
- config.active_record.migration_error = :page_load: Error if pending migrations on page load.
- config.active_record.verbose_query_logs = true: Highlight code lines for DB queries in logs.
- config.active_job.verbose_enqueue_logs = true: Highlight enqueuing locations in logs.
- config.action_controller.raise_on_missing_callback_actions = true: Raise if before_action only/except refers to missing actions.
- Commented options: i18n.raise_on_missing_translations, action_view.annotate_rendered_view_with_filenames, action_cable.disable_request_forgery_protection.

# Critical Issues
- Severity: Medium | What/Where: Caching true-branch (inside if Rails.root.join("tmp/caching-dev.txt").exist?) | Why: Missing config.action_controller.perform_caching = true means controller caching may remain off even when the toggle file exists, causing surprising behavior during dev testing of cache. | How to fix:
  - Add perform_caching in the true branch.
  ```ruby
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end
  ```

# Performance Issues
- No performance issues found

# Security Concerns
- No security concerns found

# Suggestions for Improvements
- Ensure caching toggle is complete (see Critical Issues).
- Enable fragment cache logging in dev for visibility when caching is on.
  ```ruby
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
  end
  ```
- Consider enabling view annotations to speed up template/debug navigation.
  ```ruby
  # config.action_view.annotate_rendered_view_with_filenames = true
  config.action_view.annotate_rendered_view_with_filenames = true
  ```
- Consider enabling missing translation errors in dev to catch i18n gaps early.
  ```ruby
  # config.i18n.raise_on_missing_translations = true
  config.i18n.raise_on_missing_translations = true
  ```
- Keep deprecation hygiene strict by specifying disallowed warnings as needed (helps during Rails upgrades).
  ```ruby
  config.active_support.disallowed_deprecation_warnings = [/deprecated_api_name/]
  ```