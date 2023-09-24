# frozen_string_literal: true

require "decidim/middleware/current_organization_design_app"

Rails.application.config.middleware.delete Decidim::Middleware::CurrentOrganizationDesignApp

Decidim.configure do |config|
  config.redesign_active = true
end
