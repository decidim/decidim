# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveJob::TestHelper

  config.after(:each) do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
