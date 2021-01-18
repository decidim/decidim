# frozen_string_literal: true

shared_context "when administrating a voting" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let!(:voting) { create(:voting, organization: organization) }
end
