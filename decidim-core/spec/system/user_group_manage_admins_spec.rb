# frozen_string_literal: true

require "spec_helper"

describe "User group manage admins", type: :system do
  let!(:creator) { create(:user, :confirmed) }
  let!(:user_group) { create(:user_group, users: [creator], organization: creator.organization) }
  let!(:admin) { create(:user, :confirmed, organization: creator.organization) }

  before do
    create :user_group_membership, user: admin, user_group: user_group, role: :admin

    switch_to_host(user_group.organization.host)
  end

  context "when trying to access by a basic member" do
    before do
      member = create(:user_group_membership, user_group:, role: :member).user
      login_as member, scope: :user
      visit decidim.profile_path(user_group.nickname)
    end

    it "does not show the link to edit" do
      expect(page).to have_no_content("Manage admins")
    end

    it "rejects the user that accesses manually" do
      visit decidim.group_manage_admins_path(user_group.nickname)
      expect(page).to have_content("You are not authorized to perform this action")
    end
  end

  context "when trying to edit by a manager" do
    before do
      login_as creator, scope: :user
      visit decidim.profile_path(user_group.nickname)

      click_link "Manage admins"
    end

    it "allows demoting a user" do
      accept_confirm { click_link "Remove admin" }
      expect(page).to have_content("Participant successfully removed from admin")
      expect(page).to have_no_content(admin.name)
    end
  end
end
