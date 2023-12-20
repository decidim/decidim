# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join("..", "spec", "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"

require "decidim/forms/test"
require "decidim/comments/test"
require "decidim/meetings/test/translated_event"
require "decidim/meetings/test/notifications_handling"

RSpec.configure do |config|
  config.before(:each, type: :system) do
    # Make static map requests not to fail with HTTP 500 (causes JS error)
    stub_request(:get, Regexp.new(Decidim.maps.fetch(:static).fetch(:url))).to_return(body: "")
  end
end
