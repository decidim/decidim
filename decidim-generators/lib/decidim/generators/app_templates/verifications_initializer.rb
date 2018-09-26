# frozen_string_literal: true

Decidim::Verifications.register_workflow(:dummy_authorization_handler) do |workflow|
  workflow.form = "DummyAuthorizationHandler"
  workflow.action_authorizer = "DummyAuthorizationHandler::DummyActionAuthorizer"
  workflow.expires_in = 1.hour

  workflow.options do |options|
    options.attribute :postal_code, type: :string, default: "08001", required: false
  end
end

Decidim::Verifications.register_workflow(:another_dummy_authorization_handler) do |workflow|
  workflow.form = "AnotherDummyAuthorizationHandler"
  workflow.expires_in = 1.hour

  workflow.options do |options|
    options.attribute :passport_number, type: :string, required: false
  end
end
