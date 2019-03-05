# frozen_string_literal: true

require "spec_helper"

describe "User group leaving", type: :system do
  let!(:user) { create(:user, :confirmed) }
  let!(:user_group) { create(:user_group, users: [], organization: user.organization) }

  before do
    switch_to_host(user_group.organization.host)
    login_as user, scope: :user
    visit decidim.profile_path(user_group.nickname)
  end

  context "when the user already belongs to the group" do
    context "when the user is the creator" do
      let!(:user_group) { create(:user_group, users: [user], organization: user.organization) }

      it "does not show the link to leave" do
        expect(page).to have_no_content("Leave group")
      end
    end

    it "allows the user to join" do
      create :user_group_membership, user: user, user_group: user_group, role: :admin
      visit decidim.profile_path(user_group.nickname)

      accept_confirm { click_link "Leave group" }

      expect(page).to have_content("Group successfully abandoned")
      expect(page).to have_content("Request to join group")
    end
  end

  context "when the user does not belong to the group" do
    it "does not show the link to leave" do
      expect(page).to have_no_content("Leave group")
    end
  end
end
