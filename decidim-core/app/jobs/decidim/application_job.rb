# frozen_string_literal: true

module Decidim
  class ApplicationJob < ActiveJob::Base
    # Wait until the commits on the transaction are actually on the database
    # before running the jobs, preventing possible race conditions.
    self.enqueue_after_transaction_commit = true

    # Automatically retry jobs that encountered a deadlock
    retry_on ActiveRecord::Deadlocked

    # Most jobs are safe to ignore if the underlying records are no longer available
    discard_on ActiveJob::DeserializationError
  end
end
