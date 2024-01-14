# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserGroupPresenter, type: :helper do
    let(:presenter) { described_class.new(group) }
    let(:group) { build(:user_group) }

    describe "#can_be_contacted?" do
      subject { presenter.can_be_contacted? }

      it { is_expected.to be(true) }
    end

    describe "#officialization_text" do
      subject { presenter.officialization_text }

      it { is_expected.to eq("This group is publicly verified, its name has been verified to correspond with its real name.") }
    end

    describe "#members_count" do
      subject { presenter.members_count }

      let!(:creator_membership) { create(:user_group_membership, user_group: group, role: :creator) }
      let!(:admin_memberships) { create_list(:user_group_membership, 2, user_group: group, role: :admin) }
      let!(:normal_memberships) { create_list(:user_group_membership, 3, user_group: group, role: :member) }
      let!(:pending_memberships) { create_list(:user_group_membership, 2, user_group: group, role: :invited) }

      it { is_expected.to be(6) }
    end
  end
end
