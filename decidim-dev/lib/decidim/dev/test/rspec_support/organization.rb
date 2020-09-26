# frozen_string_literal: true

RSpec.configure do |config|
  config.after do
    Decidim::OrganizationSettings.reset!
  end
end
