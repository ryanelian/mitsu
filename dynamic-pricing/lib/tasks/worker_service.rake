# frozen_string_literal: true

STDOUT.sync = true  # flush each write immediately

# This worker implements the "revalidate" half of the Stale-While-Revalidate (SWR) pattern:
# - If no keys have been cached yet, there is nothing to refresh and the loop quickly sleeps again.
# - Otherwise, it calls `RateApiService.refresh_all_cached_rates` to batch-refresh all known keys.
#
# Scheduling and quota notes:
# - The loop runs every 2 minutes (sleep 120 seconds).
# - The rate API limit is 1000 calls/day. 24×60 = 1440 minutes; 1440 / 2 = 720 cycles/day,
#   so one batch request per cycle keeps us well under the quota.
# - Each refresh is a single batch API call covering all known parameter combinations
#   (bounded number of parameter combinations: 4 periods × 3 hotels × 3 rooms = 36 max).
# - The worker keeps hot keys fresh; it does not block requests, and it makes no calls if there
#   are no cached keys.
namespace :worker_service do
  # Description for the task that appears in rake -T output
  desc "Start the worker service"

  task :run => :environment do
    Rails.logger.info "This task will start the worker service. Press Ctrl+C to stop."
    Rails.logger.info "Loading Rails environment..."

    loop do
      # Start a transaction for this iteration of the worker service
      transaction = Sentry.start_transaction(name: "worker_service_iteration", op: "worker.background")

      begin
        # Set the transaction on the scope so child spans are attached
        Sentry.get_current_scope.set_span(transaction)

        # Create a span for the rate refresh operation
        Sentry.with_child_span(op: "rate_refresh", description: "Refresh all cached rates") do |span|
          result = RateApiService.refresh_all_cached_rates

          # Add data attributes to the span
          span&.set_data("cached_keys_count", result[:updated] + result[:errors])
          span&.set_data("updated_count", result[:updated])
          span&.set_data("error_count", result[:errors])

          Rails.logger.info "Rate refresh completed: #{result[:updated]} updated, #{result[:errors]} errors"
        end

      rescue => e
        Rails.logger.error "Error in worker service iteration: #{e.message}"
        # Capture any errors in the transaction
        Sentry.capture_exception(e)
      ensure
        # Always finish the transaction
        transaction&.finish
      end

      # Sleep for 120 seconds (2 minutes)
      sleep 120
    end
  end
end
