# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveJob::TestHelper

  config.around :example, perform_enqueued: true do
    perform_enqueued_jobs do
      example.run
    end
  end

  config.after(:each) do
    clear_enqueued_jobs
  end
end

ActiveJob::Base.queue_adapter = :test
