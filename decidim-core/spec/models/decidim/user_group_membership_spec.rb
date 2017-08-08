# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe UserGroupMembership do
    subject { create(:user_group_membership) }

    it "is valid" do
      expect(subject).to be_valid
    end

    it "has an association user" do
      expect(subject.user).to be_a(Decidim::User)
    end

    it "has an association user group" do
      expect(subject.user_group).to be_a(Decidim::UserGroup)
    end
  end
end
