# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserGroups::InvitedMemberships do
  subject { described_class.for(user) }

  let(:organization) { create(:organization) }
  let(:user) { create :user, organization: organization }

  let(:creator_membership) { create :user_group_membership, user: user, role: :creator }
  let(:admin_membership) { create :user_group_membership, user: user, role: :admin }
  let(:member_membership) { create :user_group_membership, user: user, role: :member }
  let(:requested_membership) { create :user_group_membership, user: user, role: :requested }
  let(:invited_membership) { create :user_group_membership, user: user, role: :invited }

  it "finds the user groups where the user has a pending membership" do
    expect(subject).to match_array([invited_membership])
  end
end
