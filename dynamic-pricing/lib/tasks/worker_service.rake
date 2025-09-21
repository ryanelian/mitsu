# frozen_string_literal: true

STDOUT.sync = true  # flush each write immediately

# Rake task namespace for logging utilities
namespace :worker_service do
  # Description for the task that appears in rake -T output
  desc "Start the worker service"

  task :run => :environment do
    Rails.logger.info "This task will start the worker service. Press Ctrl+C to stop."
    Rails.logger.info "Loading Rails environment..."

    loop do
      RateApiService.refresh_all_cached_rates

      # Sleep for 120 seconds (2 minutes)
      sleep 120
    end
  end
end
