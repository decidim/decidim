# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveJob::TestHelper

  config.around do |example|
    perform_enqueued_jobs do
      example.run
    end
  end

  config.around(:each, :with_inline_queue) do |example|
    old_adapter = Rails.application.config.active_job.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
    example.run
    ActiveJob::Base.queue_adapter = old_adapter
  end

  config.after(:each) do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
