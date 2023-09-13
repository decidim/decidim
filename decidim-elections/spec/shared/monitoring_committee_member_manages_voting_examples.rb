# frozen_string_literal: true

shared_context "when monitoring committee member manages voting" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin_terms_accepted, organization: organization) }
  let(:voting) { create(:voting, organization: organization) }

  let!(:monitoring_committee_member) { create(:monitoring_committee_member, user: user, voting: voting) }
end
