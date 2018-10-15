# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserGroupMembership do
    subject { membership }

    let(:membership) { create(:user_group_membership) }

    it "is valid" do
      expect(subject).to be_valid
    end

    it "has an association user" do
      expect(subject.user).to be_a(Decidim::User)
    end

    it "has an association user group" do
      expect(subject.user_group).to be_a(Decidim::UserGroup)
    end

    describe "validations" do
      it "is not valid with a weird role" do
        membership = build :user_group_membership, role: :foo_bar_does_not_exist
        expect(membership).not_to be_valid
      end

      it "can't have multiple creators for the same user group" do
        membership = create :user_group_membership, role: :creator
        failing_membership = build :user_group_membership, role: :creator, user_group: membership.user_group

        expect(failing_membership).not_to be_valid
      end

      it "can have multiple roles different from creator for the same user group" do
        membership = create :user_group_membership, role: :admin
        membership2 = build :user_group_membership, role: :admin, user_group: membership.user_group

        expect(membership2).to be_valid
      end
    end
  end
end
