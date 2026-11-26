# frozen_string_literal: true

if Rails.env.production? || Rails.env.test?
  require "rack/attack"
  require "decidim/rack_attack_rules"

  Rails.application.configure do |config|
    config.middleware.use Rack::Attack
  end

  ActiveSupport::Reloader.to_prepare do
    Decidim::RackAttackRules.register_blocklists!

    # Throttling is disabled in the test environment so specs are not throttled.
    # The specs load the rules in isolation instead (see
    # decidim-core/spec/config/initializers/rack/attack_spec.rb).
    Decidim::RackAttackRules.register_throttles! unless Rails.env.test?
  end
end
