# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveJob::TestHelper
end

ActiveJob::Base.queue_adapter = :test
