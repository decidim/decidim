# frozen_string_literal: true
require "decidim/dummy_authorization_handler"
RSpec.configure do |config|
  config.before(:each) do
    Decidim.config.authorization_handlers = [Decidim::DummyAuthorizationHandler]
  end
end
