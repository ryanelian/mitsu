# Service Tests

This directory contains comprehensive unit and integration tests for all services in the dynamic-pricing application.

## Test Files

### `app_settings_test.rb`
Tests the `AppSettings` module which handles environment variable access:
- Tests all environment variable getters (redis_url, rate_api_url, rate_api_token, rate_api_quota)
- Tests error handling for missing/blank environment variables
- Tests type conversion (quota string to integer)

### `problem_details_test.rb`
Tests the `ProblemDetails` module for RFC 7807 compliant error responses:
- Tests validation error creation with required and optional parameters
- Tests service unavailable error creation
- Tests JSON serialization compatibility
- Tests all constants and default values

### `validation_helpers_test.rb`
Tests the `ValidationHelpers` module for field validation:
- Tests presence validation
- Tests set membership validation
- Tests error message formatting
- Tests edge cases (empty sets, single items, case sensitivity)

### `redis_repository_test.rb`
Tests the `RedisRepository` singleton for Redis operations:
- Tests basic key-value operations (get, set, TTL)
- Tests counter operations (increment, increment_by, get_counter)
- Tests set operations (add_to_set, get_set_members)
- Tests distributed locking with Redlock algorithm
- Tests concurrent access patterns
- Tests error handling and connection health

### `rate_api_client_test.rb`
Tests the `RateApiClient` for external API communication:
- Tests single and batch rate fetching against real API
- Tests URI building and request formatting
- Tests response parsing and error handling
- Tests timeout handling and network resilience
- Tests consistency between single and batch operations

### `rate_api_service_test.rb`
Tests the `RateApiService` for rate caching and quota management:
- Tests rate fetching with cache stampede prevention
- Tests distributed locking for concurrent access
- Tests API quota management and enforcement
- Tests cache refresh operations
- Tests error handling and service unavailability
- Tests hit counting and metrics

## Test Approach

These tests follow the requirements:
- **NO MOCKING**: All tests use real Redis and real rate API
- **Simple and Direct**: Tests focus on behavior verification without complex setup
- **Integration Testing**: Tests verify end-to-end functionality with real dependencies
- **Error Handling**: Tests verify graceful error handling and edge cases

## Running Tests

Use the provided test script:
```bash
./test.sh
```

This runs all tests against the real Redis instance and rate API server in the Docker environment.

## Test Coverage

The tests cover:
- ✅ Happy path scenarios with valid data
- ✅ Error conditions and edge cases
- ✅ Concurrent access patterns
- ✅ Cache behavior and TTL
- ✅ API quota management
- ✅ Network resilience and timeouts
- ✅ Data consistency and integrity
- ✅ Service availability patterns