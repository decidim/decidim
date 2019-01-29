# frozen_string_literal: true

Decidim::Initiatives.configure do |config|
  config.timestamp_service = "Decidim::Initiatives::DummyTimestamp"
end
