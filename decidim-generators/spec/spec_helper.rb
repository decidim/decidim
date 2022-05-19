# frozen_string_literal: true

require "decidim/generators"

RSpec.configure do |config|
  config.fail_fast = ENV.fetch("FAIL_FAST", nil) == "true"
end
