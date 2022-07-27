# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserGroups::InvitedMemberships do
  subject { described_class.for(user) }

  let(:organization) { create(:organization) }
  let(:user) { create :user, organization: }

  let(:creator_membership) { create :user_group_membership, user:, role: :creator }
  let(:admin_membership) { create :user_group_membership, user:, role: :admin }
  let(:member_membership) { create :user_group_membership, user:, role: :member }
  let(:requested_membership) { create :user_group_membership, user:, role: :requested }
  let(:invited_membership) { create :user_group_membership, user:, role: :invited }

  it "finds the user groups where the user has a pending membership" do
    expect(subject).to match_array([invited_membership])
  end
end
