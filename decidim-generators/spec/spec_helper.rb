# frozen_string_literal: true

require "decidim/generators"

ENV["RETRY_TIMES"] = "0"

RSpec.configure do |config|
  config.fail_fast = ENV["FAIL_FAST"] == "true"
end
