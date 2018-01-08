# frozen_string_literal: true

Decidim::Verifications.register_workflow(:dummy_authorization_handler) do |workflow|
  workflow.form = "Decidim::DummyAuthorizationHandler"
  workflow.action_authorizer = "Decidim::DummyAuthorizationHandler::ActionAuthorizer"
  workflow.expires_in = 1.hour
end
