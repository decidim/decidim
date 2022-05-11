# frozen_string_literal: true

require "decidim/generators"

RSpec.configure do |config|
  config.fail_fast = ENV["FAIL_FAST"] == "true"
end
