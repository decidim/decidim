# frozen_string_literal: true

shared_context "authorization transfer" do
  let(:organization) { create(:organization) }
  let(:original_user) { create(:user, :confirmed, :deleted, organization: organization) }
  let(:target_user) { create(:user, :confirmed, organization: organization) }
  let(:authorization_document_number) { "12345678X" }
  let(:authorization) { create(:authorization, :granted, user: original_user, unique_id: authorization_document_number) }
  let(:authorization_handler) do
    DummyAuthorizationHandler.from_params(
      document_number: authorization_document_number,
      user: target_user
    )
  end

  before do
    original_records # Make sure the original records exist before publishing the notification
    Decidim::AuthorizationTransfer.publish(authorization, authorization_handler)
  end
end
