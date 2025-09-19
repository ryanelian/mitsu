# Dynamic Pricing Proxy

## The Challenge

A dynamic pricing model is used for hotel rooms. Instead of static, unchanging rates, a model uses a real-time algorithm to adjust prices based on market demand and other data signals. This helps us maximize both revenue and occupancy.

A Data and AI team built a powerful model to handle this, but its inference process is computationally expensive to run. To make this product more cost-effective, we analyzed the model's output and found that a calculated room rate remains effective for up to 5 minutes.

This efficient service that acts as an intermediary to the dynamic pricing model. This service will be responsible for providing rates to the users while respecting the operational constraints of the expensive model behind it.

## Core Requirements

1.  Integrate the Pricing Model: Modify the provided service to call the external dynamic pricing API to get the latest rates. The model is available as a Docker image: [tripladev/rate-api](https://hub.docker.com/r/tripladev/rate-api).

2.  Ensure Rate Validity: A rate fetched from the pricing model is considered valid for 5 minutes. The service must ensure that any rate it provides for a given set of parameters (`period`, `hotel`, `room`) is no older than this 5-minute window.

3.  Honor API Usage Limits: The model's API token is limited. The solution must be able to handle at least 10,000 requests per day from the users while using a single API token for the pricing model.

## Development Environment Setup

The project scaffold is a minimal Ruby on Rails application with a `/pricing` endpoint. This repository is pre-configured for a Docker-based workflow that supports live reloading for your convenience.

The provided `Dockerfile` builds a container with all necessary dependencies. Your local code is mounted directly into the container, so any changes you make on your machine will be reflected immediately. Your application will need to communicate with the external pricing model, which also runs in its own Docker container.

### Quick Start Guide

Here is a list of common commands for building, running, and interacting with the Dockerized environment.

```bash

# --- 1. Build & Run The Main Application ---
# Build the Docker image
docker build -t interview-app .

# Run the service
docker run -p 3000:3000 -v $(pwd):/rails interview-app

# --- 2. Test The Endpoint ---
# Send a sample request to your running service
curl 'http://localhost:3000/pricing?period=Summer&hotel=FloatingPointResort&room=SingletonRoom'

# --- 3. Run Tests ---
# Run the development container in the background
docker run -d -p 3000:3000 -v $(pwd):/rails --name interview-dev interview-app

# Run the full test suite
docker container exec -it interview-dev ./bin/rails test

# Run a specific test file
docker container exec -it interview-dev ./bin/rails test test/controllers/pricing_controller_test.rb

# Run a specific test by name
docker container exec -it interview-dev ./bin/rails test test/controllers/pricing_controller_test.rb -n test_should_get_pricing_with_all_parameters
```
