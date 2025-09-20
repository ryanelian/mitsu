# Executive Summary
- File: config/initializers/filter_parameter_logging.rb
- TL;DR: Boot-time Rails initializer that configures which incoming request parameters are redacted from logs using partial key matching. This protects sensitive data (e.g., tokens, secrets, SSNs) from being written to application logs.

# Ruby Concepts
| Ruby Concept | What It Is | C#/TS Analogy |
| --- | --- | --- |
| Symbol (e.g., :token) | Immutable, interned identifier used as lightweight keys | C#: interned string or enum-like key; TS: symbol or string literal keys |
| Array literal [...] | Ordered collection of items | C#: List<T> initialization; TS: Array<T> |
| Array concatenation (+=) | Appends items to an existing array | C#: list.AddRange(...); TS: arr.push(...items) or arr = [...arr, ...items] |
| Namespaced constant (Rails) | Top-level module providing framework access | C#: static namespace/class (e.g., Microsoft.AspNetCore.…) |
| Method chaining (Rails.application.config) | Accessing nested objects via dot calls | C#: builder.Services / app.Configuration chaining |
| Comment (# ...) | Single-line code comments | C#/TS: // ... |

# Rails Concepts
| Rails Concept | What It Is | ASP.NET/React Analogy |
| --- | --- | --- |
| Initializer (config/initializers) | Code executed at app boot to configure framework behavior | ASP.NET Core: Program.cs/Startup.cs configuration at startup |
| filter_parameters | List of parameter key matchers to redact in logs | ASP.NET Core: HttpLogging + redaction/masking policies or Serilog destructuring policies |
| Partial matching for keys | Symbols like :passw match any param containing that substring | ASP.NET Core: custom middleware/filter that masks keys by substring/regex |
| ActiveSupport::ParameterFilter | Engine that applies the filtering rules | ASP.NET Core: custom IInputFormatter/logging middleware with redaction |
| Global effect on controller logs | Affects params in controller/request logs | ASP.NET Core: Request logging middleware affecting all endpoints |

# Code Anatomy
- Rails.application.config.filter_parameters: Array of matchers controlling which parameter keys get redacted in logs.
- += [ :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn ]: Appends a set of partial-match symbols to the existing filter list. Any param key containing these substrings will have its value replaced with "[FILTERED]" in logs.

# Critical Issues
No critical bugs found

# Performance Issues
No performance issues found

# Security Concerns
No security concerns found

# Suggestions for Improvements
- Broaden coverage to more common sensitive fields
  - Rationale: Reduce risk of leaking secrets (headers, auth, payments) not covered by current list.
  - Example:
    ```ruby
    Rails.application.config.filter_parameters += [
      :password, :password_confirmation, :authorization, :auth, :bearer,
      :api_key, :access_key, :refresh_token, :session, :cookie, :card, :cvv
    ]
    ```

- Use case-insensitive regex for header names and variants
  - Rationale: Header casing varies and keys may differ slightly across clients.
  - Example:
    ```ruby
    Rails.application.config.filter_parameters += [
      /authorization/i, /api[-_]?key/i, /access[-_]?token/i
    ]
    ```

- Prefer precise substrings to avoid over-filtering while keeping safety
  - Rationale: Very broad substrings (e.g., :_key) may mask benign fields and hinder troubleshooting. Narrow where possible.
  - Before:
    ```ruby
    :_key
    ```
  - After:
    ```ruby
    :api_key, :private_key, :public_key
    ```

- Ensure nested and query params are accounted for
  - Rationale: Filtering applies to nested structures; include likely nested keys to ensure coverage.
  - Example:
    ```ruby
    Rails.application.config.filter_parameters += [
      :credentials, :metadata, :headers
    ]
    ```

- Keep a short comment documenting intent and scope
  - Rationale: Aids maintenance and onboarding (what’s masked and why).
  - Example:
    ```ruby
    # Mask common auth, credential, and payment fields (request body, query, and headers).
    ```