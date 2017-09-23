# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    Decidim.config.authorization_handlers = [Decidim::DummyAuthorizationHandler]
  end
end
