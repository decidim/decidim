# frozen_string_literal: true
ENV["ENGINE_NAME"] = File.dirname(File.dirname(__FILE__)).split("/").last

require "decidim/dev/test/base_spec_helper"
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include ProcessesMenuLinksHelpers
end
