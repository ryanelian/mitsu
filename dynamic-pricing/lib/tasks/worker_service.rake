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
      RateApiService.refresh_all_cached_rates

      # Sleep for 120 seconds (2 minutes)
      sleep 120
    end
  end
end
