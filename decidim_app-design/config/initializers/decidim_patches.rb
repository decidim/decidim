# frozen_string_literal: true

Rails.application.config.middleware.delete Decidim::Middleware::CurrentOrganization

Decidim.configure do |config|
  config.redesign_active = true
end
