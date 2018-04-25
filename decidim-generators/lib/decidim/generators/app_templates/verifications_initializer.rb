# frozen_string_literal: true

Decidim::Verifications.register_workflow(:dummy_authorization_handler) do |workflow|
  workflow.form = "DummyAuthorizationHandler"
  workflow.action_authorizer = "DummyAuthorizationHandler::ActionAuthorizer"
  workflow.expires_in = 1.hour
end

Decidim::Verifications.register_workflow(:another_dummy_authorization_handler) do |workflow|
  workflow.form = "AnotherDummyAuthorizationHandler"
  workflow.expires_in = 1.hour
end
