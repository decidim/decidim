# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserGroups::AcceptedUsers do
  subject { described_class.for(user_group) }

  let(:organization) { create(:organization) }

  let!(:creator_user) { create :user, organization: }
  let!(:admin_user) { create :user, organization: }
  let!(:member_user) { create :user, organization: }
  let!(:requested_user) { create :user, organization: }

  let!(:user_group) { create :user_group, organization:, users: [] }

  before do
    create :user_group_membership, user: creator_user, user_group: user_group, role: :creator
    create :user_group_membership, user: admin_user, user_group: user_group, role: :admin
    create :user_group_membership, user: member_user, user_group: user_group, role: :member
    create :user_group_membership, user: requested_user, user_group:, role: :requested
  end

  it "finds the active members for the user group" do
    expect(subject).to match_array([creator_user, admin_user, member_user])
  end
end
