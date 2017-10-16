# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveJob::TestHelper

  config.around :example, perform_enqueued: true do |example|
    perform_enqueued_jobs { example.run }
  end

  config.after(:each) do
    clear_enqueued_jobs
  end
end

ActiveJob::Base.queue_adapter = :test
