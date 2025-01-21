# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveJob::TestHelper

  config.before(:each) do
    ActiveJob::Base.queue_adapter = :inline
  end

  config.after(:each) do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
