# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.6
FROM ruby:$RUBY_VERSION-alpine

# Rails app lives here
WORKDIR /rails

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT=""

# Install packages needed for development
RUN apk add --no-cache \
    build-base \
    git \
    pkgconfig \
    curl \
    sqlite-dev \
    sqlite \
    tzdata

# Install application gems
COPY Gemfile Gemfile.lock /rails/
RUN bundle install --gemfile=/rails/Gemfile

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["sh", "-c", "./bin/rails db:prepare && ./bin/rails server -b 0.0.0.0"]
