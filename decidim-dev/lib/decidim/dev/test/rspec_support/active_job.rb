# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveJob::TestHelper

  config.after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  config.before do
    ActiveJob::Base.queue_adapter = :inline
  end
end
