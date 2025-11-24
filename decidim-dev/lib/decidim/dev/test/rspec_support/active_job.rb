# frozen_string_literal: true

module DecidimActiveJobExtensions
  def wait_enqueued_jobs(&block)
    while enqueued_jobs.size.positive?
      perform_enqueued_jobs
      sleep(1)
    end

    yield block
  end
end

RSpec.configure do |config|
  config.include ActiveJob::TestHelper
  config.include DecidimActiveJobExtensions
end

ActiveJob::Base.queue_adapter = :test
