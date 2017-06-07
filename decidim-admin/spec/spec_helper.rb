# frozen_string_literal: true

ENV["ENGINE_NAME"] = File.dirname(__dir__).split("/").last

require "decidim/dev/test/base_spec_helper"

Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include ProcessesMenuLinksHelpers
end
