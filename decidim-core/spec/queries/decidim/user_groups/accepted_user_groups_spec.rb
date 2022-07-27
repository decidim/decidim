# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserGroups::AcceptedUserGroups do
  subject { described_class.for(user) }

  let(:organization) { create(:organization) }
  let(:user) { create :user, organization: }

  let!(:creator_user_group) { create :user_group, organization:, users: [] }
  let!(:admin_user_group) { create :user_group, organization:, users: [] }
  let!(:member_user_group) { create :user_group, organization:, users: [] }
  let!(:requested_user_group) { create :user_group, organization:, users: [] }

  before do
    create :user_group_membership, user: user, user_group: creator_user_group, role: :creator
    create :user_group_membership, user: user, user_group: admin_user_group, role: :admin
    create :user_group_membership, user: user, user_group: member_user_group, role: :member
    create :user_group_membership, user:, user_group: requested_user_group, role: :requested
  end

  it "finds the user groups where the user has an accepted membership" do
    expect(subject).to match_array([creator_user_group, admin_user_group, member_user_group])
  end
end
