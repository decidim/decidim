# frozen_string_literal: true

shared_context "authorization transfer" do
  let(:organization) { create(:organization) }
  let(:original_user) { create(:user, :confirmed, :deleted, organization:) }
  let(:target_user) { create(:user, :confirmed, organization:) }
  let(:authorization_document_number) { "12345678X" }
  let(:authorization) { create(:authorization, :granted, user: original_user, unique_id: authorization_document_number) }
  let(:authorization_handler) do
    DummyAuthorizationHandler.from_params(
      document_number: authorization_document_number,
      user: target_user
    )
  end
  let(:transfer) do
    create(
      :authorization_transfer,
      authorization:,
      user: authorization_handler.user,
      source_user: original_user
    )
  end
  let(:transferred_resources) { transfer.records.map(&:resource).sort_by! { |r| "#{r.class.name}##{format("%010d", r.id)}" } }

  before do
    # Make sure the original records exist before publishing the notification
    original_records

    # The initializer should have already been run when the test starts, so when
    # the transfer is announced, it should handle the event subscription
    # correctly if it has run and works as expected.
    transfer.announce!(authorization_handler)
  end
end
