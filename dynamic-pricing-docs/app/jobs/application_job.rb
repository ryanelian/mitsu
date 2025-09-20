# frozen_string_literal: true
# ---------------------------------------------------------------------------
# ApplicationJob
#
# Purpose:
# - This is the base class for all background jobs in a Rails app.
# - In Rails, jobs encapsulate work that should run asynchronously or outside
#   the normal HTTP request/response cycle (e.g., sending emails, processing
#   files, calling APIs).
#
# Parallels to C# / ASP.NET Core:
# - Conceptually similar to background jobs you might run via Hangfire,
#   Quartz.NET, or Azure WebJobs. ActiveJob is an abstraction that can run on
#   different queue backends (adapters), similar to how you can swap providers.
# - Think of this as an "abstract base class" for jobs. Ruby doesn't enforce
#   abstract types; it's a convention. All your jobs should subclass this.
#
# Rails conventions and autoloading:
# - File path app/jobs/application_job.rb maps to class ApplicationJob by
#   convention. Rails autoloads constants based on this path/name convention.
#
# How to use in practice:
# - Create a job class inheriting from ApplicationJob:
#     class SendReportJob < ApplicationJob
#       queue_as :default
#       def perform(user_id)
#         # do work here
#       end
#     end
# - Enqueue asynchronously: SendReportJob.perform_later(user_id)
#   (roughly analogous to scheduling/enqueueing a background task in C#).
# - Run immediately in the current process/thread: SendReportJob.perform_now(user_id)
#   (similar to directly invoking a method; useful for synchronous execution in dev/tests).
#
# Adapters / Runners:
# - ActiveJob provides a unified API; the actual queue runner is pluggable
#   (e.g., :async – in-process, or external systems like Sidekiq, Resque, etc.).
# - Configure adapter in config/application.rb or per-environment config:
#     config.active_job.queue_adapter = :async
# - No external libs are required to understand this file; just know the adapter
#   determines where jobs are persisted/executed.
#
# Serialization:
# - Arguments to perform are serialized. ActiveRecord models are passed using
#   GlobalID (a reference) rather than a full object snapshot. If the record is
#   deleted by the time the job runs, look at discard_on below.
#
# Error handling:
# - ActiveJob provides DSL methods like retry_on and discard_on to handle
#   exceptions declaratively (similar to setting retry policies in Hangfire or
#   Polly policies in C#).
#
# Testing/middleware:
# - In tests, you can use ActiveJob::TestHelper to assert enqueued jobs.
# - Middlewares can wrap job execution depending on the adapter.
# ---------------------------------------------------------------------------
class ApplicationJob < ActiveJob::Base # Inherit shared behavior/config for all jobs from ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked
  # - retry_on is a class-level macro that declares automatic retry behavior      # (Ruby "macro" via class method; similar to attributes/config in C#)
  # - If uncommented, jobs raising ActiveRecord::Deadlocked would be retried      # Useful for transient DB issues (deadlocks/timeouts)
  # - Options include :wait, :attempts, etc., e.g.: retry_on(SomeError, wait: 5.seconds, attempts: 3)
  # - Keep jobs idempotent so retries don't cause duplicate side effects          # Same advice as in distributed systems with retries

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
  # - discard_on swallows specified exceptions and drops the job                  # No retry, no re-raise
  # - ActiveJob::DeserializationError occurs when serialized arguments (e.g., a   # GlobalID for a record) can’t be reloaded—often because it was deleted
  # - Use this when the work is no longer relevant if the record is gone          # e.g., sending an email to a deleted user

  # Additional common patterns you might see (shown here as comments for reference):
  # - queue_as :default           # sets which queue the job uses (akin to a named queue/topic)
  # - around_perform :benchmark   # run callbacks around perform (before/after hooks)
  # - rescue_from(SomeError) { |e| … }  # custom error handling per job
end # end of ApplicationJob class definition