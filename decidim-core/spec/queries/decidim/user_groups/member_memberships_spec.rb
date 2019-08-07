# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserGroups::MemberMemberships do
  subject { described_class.for(user_group) }

  let(:organization) { create(:organization) }

  let!(:user_group) { create :user_group, organization: organization, users: [] }

  let!(:creator) { create :user_group_membership, user_group: user_group, role: :creator }
  let!(:admin) { create :user_group_membership, user_group: user_group, role: :admin }
  let!(:member) { create :user_group_membership, user_group: user_group, role: :member }
  let!(:requested) { create :user_group_membership, user_group: user_group, role: :requested }

  it "finds the member memberships for the user group" do
    expect(subject).to match_array([member])
  end
end
