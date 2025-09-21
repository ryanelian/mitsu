# Dynamic Pricing Proxy

## The Challenge

A dynamic pricing model is used for hotel rooms. Instead of static, unchanging rates, a model uses a real-time algorithm to adjust prices based on market demand and other data signals. This helps us maximize both revenue and occupancy.

A Data and AI team built a powerful model to handle this, but its inference process is computationally expensive to run. To make this product more cost-effective, we analyzed the model's output and found that a calculated room rate remains effective for up to 5 minutes.

This efficient service that acts as an intermediary to the dynamic pricing model. This service will be responsible for providing rates to the users while respecting the operational constraints of the expensive model behind it.

## Core Requirements

1.  Integrate the Pricing Model: Modify the provided service to call the external dynamic pricing API to get the latest rates. The model is available as a Docker image: [tripladev/rate-api](https://hub.docker.com/r/tripladev/rate-api).

2.  Ensure Rate Validity: A rate fetched from the pricing model is considered valid for 5 minutes. The service must ensure that any rate it provides for a given set of parameters (`period`, `hotel`, `room`) is no older than this 5-minute window.

3.  Respect External Model Capacity: The external `rate-api` can process at most 1,000 requests per day per API token. Do not exceed this cap; serve additional demand using caching and request coalescing. Reference: [tripladev/rate-api](https://hub.docker.com/r/tripladev/rate-api).

4.  Scale the Proxy: The proxy must handle at least 10,000 requests per day and should scale horizontally (multiple instances behind a load balancer) to support millions of requests per day while maintaining the 5-minute rate validity constraint.

## Architecture

- This project employs modern caching strategy with SWR (Stale-While-Revalidating):
  - Fast path (stale data): if a requested `(period, hotel, room)` is cached, the API returns it immediately.
  - On cache miss, we acquire a short-lived distributed lock (per key), fetch from the upstream Rate API, store for 5 minutes (300s), and return the fresh value. This prevents cache stampedes and keeps requests fast for end-users.
  - Revalidation: a background worker runs every 2 minutes to batch-refresh all previously requested keys. If there are no cached keys, the worker does nothing.

- Data validity and refresh cadence:
  - Cache TTL is 5 minutes.
  - Worker refresh runs every 2 minutes, so stale values are refreshed well before expiry in normal operation.

- Quota and batching:
  - Upstream limit: 1000 calls/day.
  - 1 day = 24 hours × 60 minutes = 1440 minutes; with a 2-minute interval there are 720 refresh cycles/day.
  - The batch endpoint accepts an array of parameter sets. For this API the domain is bounded: 4 periods × 3 hotels × 3 rooms = 36 maximum combinations.
  - Therefore, in a single day, the total number of API calls is bounded by 720 (worker) + 36 (first-time misses) = 756, well under the 1000 limit.

- Behavior with no cached keys:
  - The worker does nothing if no keys were requested yet. New keys are populated on-demand by request-path misses.

## Distributed Trace

The application is instrumented with [Sentry.io](https://sentry.io/) for distributed tracing and error monitoring. Sentry automatically captures performance traces showing the flow between the Rails API, Redis cache, distributed locks, and external Rate API.

In addition, Sentry provides centralized logging and automatic error triage for both the web application and background worker processes.

To enable Sentry tracing in your local environment, set the `SENTRY_DSN` environment variable:

```bash
export SENTRY_DSN="https://your-dsn@sentry.io/project-id"
```

If no `SENTRY_DSN` is provided, the application will continue to run normally without Sentry (it will only log a warning message).

The traces below show typical request flows captured by Sentry:

### Cache Hit
![Distributed trace showing cache hit scenario](img/dtrace_cache_hit.png)

### Cache Miss
![Distributed trace showing cache miss scenario](img/dtrace_cache_miss.png)

### Background Worker
![Distributed trace showing background worker refresh](img/dtrace_worker.png)

## Sequence Diagram

```mermaid
sequenceDiagram
    autonumber
    participant C as Client
    participant A as Rails API
    participant R as Valkey (Redis)
    participant L as Distributed Lock
    participant U as Rate API

    Note over C,A: Request Path (GET /pricing)
    C->>A: GET /pricing?period=..&hotel=..&room=..
    A->>R: GET key(period,hotel,room)
    alt Cache hit
      R-->>A: cached rate
      A-->>C: 200 { rate }
    else Cache miss
      R-->>A: (nil)
      A->>L: Acquire per-key lock (TTL ~30s)
      alt Lock acquired
        A->>U: fetch_rate(period, hotel, room)
        U-->>A: rate
        A->>R: SET key = rate (TTL 300s)
        A->>R: SADD rate_cache_keys key
        A-->>C: 200 { rate }
      else Lock not acquired (rare)
        A-->>C: 503 Service Unavailable
      end
    end

    Note over A,R: Background worker (every 120s)
    A->>R: SMEMBERS rate_cache_keys
    alt No cached keys
      R-->>A: empty (do nothing)
    else Has cached keys
      A->>U: fetch_rates(batch requests)
      U-->>A: rates_dict
      A->>R: SET each key = rate (TTL 300s)
    end
```

## API Endpoint

GET `/pricing?period=Summer&hotel=FloatingPointResort&room=SingletonRoom`

- Allowed values:
  - `period`: `Summer`, `Autumn`, `Winter`, `Spring`
  - `hotel`: `FloatingPointResort`, `GitawayHotel`, `RecursionRetreat`
  - `room`: `SingletonRoom`, `BooleanTwin`, `RestfulKing`

Responses:
- 200 `{ "rate": "<value>" }`
- 400 Problem Details (invalid parameters)
- 503 Problem Details (temporary unavailability)

## Development Environment Setup

The project scaffold is a minimal Ruby on Rails application with a `/pricing` endpoint. This repository is pre-configured for a Docker-based workflow that supports live reloading for your convenience.

The provided `Dockerfile` builds a container with all necessary dependencies. Your local code is mounted directly into the container, so any changes you make on your machine will be reflected immediately. Your application will need to communicate with the external pricing model, which also runs in its own Docker container.

## Frontend User Interface

The project includes a modern Next.js React-based frontend application (`dynamic-pricing-ui/`) that provides a complete user experience for testing and monitoring the dynamic pricing proxy.

### Running the Frontend

To start the frontend development server:

```bash
brew install fnm
fnm install
fnm use
npm install -g pnpm
cd dynamic-pricing-ui
pnpm install
pnpm dev
```

The UI will be available at `http://localhost:3001`.

### Capabilities

The frontend application provides comprehensive testing and monitoring tools:

#### 🧮 **Pricing Calculator**
- Interactive form to test pricing requests with all valid (and invalid) parameter combinations
- Real-time rate calculation display
- Validation and error handling
- Last updated timestamp tracking

#### 📊 **System Health & Metrics Dashboard**
- Real-time system status monitoring (API status, Redis connectivity)
- Live metrics display (quota usage, API call counts, hit rates)
- Visual indicators for system health
- Auto-refreshing data with configurable intervals
- Animated circular progress indicator to next refresh time

#### ⚡ **Stress Testing Suite**
- **Comprehensive Burst Test**: 360 concurrent requests testing all parameter combinations
- **Randomized Sustained Test**: 1 million sequential requests for load testing
- Real-time progress tracking with animated progress bars
- Detailed performance metrics (success rates, response times, throughput)

### Backend-for-Frontend (BFF) Architecture

This app implements an API Gateway pattern that forwards requests from `localhost:3001` to `localhost:3000` (Dynamic Pricing Proxy Rails API). This approach:

- ✅ **Bypasses CORS restrictions** - more secure
- ✅ **Enhances security** - allows not exposing public API directly and allows OAuth 2.0 Proxy to be implemented in the future
- ✅ **Separation of concerns** - API calls to microservices can be aggregated in `/api` routes in the front-end.

![Frontend Dashboard Screenshot](img/dashboard.png)

## Quick Start Guide

### 1) Build the Rails app image

Use the helper script to build the Rails API image from `dynamic-pricing/`.

```bash
./build.sh
```

This produces a local image named `dynamic-pricing-proxy`.

### 2) Start the full dev stack

Use docker-compose via the helper script. This:
- mounts `dynamic-pricing/` into the Rails container for live reload
- starts the Rails API, the external rate API, Valkey (Redis-compatible), and RedisInsight

```bash
./dev.sh
```

To view logs:
```bash
docker compose logs -f | cat
```

### 3) Test the pricing endpoint

```bash
curl 'http://localhost:3000/pricing?period=Summer&hotel=FloatingPointResort&room=SingletonRoom'
```

### 4) Run tests

Use the helper script, which runs the full suite inside the running app container:
```bash
./test.sh
```

Run a specific test file:
```bash
docker exec -it dynamic-pricing-proxy ./bin/rails test test/controllers/pricing_controller_test.rb
```

Run a specific test by name:
```bash
docker exec -it dynamic-pricing-proxy ./bin/rails test test/controllers/pricing_controller_test.rb -n test_should_get_pricing_with_all_parameters
```

## Service Ports

| Service         | Container Name           | Host Port | Container Port |
|-----------------|--------------------------|-----------|----------------|
| Rails API       | `dynamic-pricing-proxy`  | 3000      | 3000           |
| Rate API        | `rate-api`               | 8080      | 8080           |
| Valkey (Redis)  | `valkey`                 | 6379      | 6379           |
| RedisInsight    | `redisinsight`           | 5540      | 5540           |

## Teardown

Stop and remove all services started by docker-compose:
```bash
./teardown.sh
```

If you need to remove containers, networks, and volumes forcefully:
```bash
docker compose down -v --remove-orphans
```
