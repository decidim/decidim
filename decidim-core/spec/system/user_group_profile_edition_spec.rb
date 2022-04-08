# frozen_string_literal: true

require "spec_helper"

describe "User group profile edition", type: :system do
  let!(:creator) { create(:user, :confirmed) }
  let!(:user_group) { create(:user_group, users: [creator], organization: creator.organization) }
  let!(:member) { create(:user, :confirmed, organization: creator.organization) }

  before do
    create :user_group_membership, user: member, user_group: user_group, role: :member

    switch_to_host(user_group.organization.host)
  end

  context "when trying to edit by a basic member" do
    before do
      login_as member, scope: :user
      visit decidim.profile_path(user_group.nickname)
    end

    it "does not show the link to edit" do
      expect(page).to have_no_content("Edit group profile")
    end

    it "rejects the user that accesses manually" do
      visit decidim.group_manage_users_path(user_group.nickname)
      expect(page).to have_content("You are not authorized to perform this action")
    end
  end

  context "when trying to edit by a manager" do
    before do
      login_as creator, scope: :user
      visit decidim.profile_path(user_group.nickname)
    end

    it "allows editing the profile" do
      expect(page).to have_content("Edit group profile")
      click_link "Edit group profile"

      fill_in "Name", with: "My super duper group"
      fill_in "About", with: "We are awesome"
      dynamically_attach_file(:group_avatar, Decidim::Dev.asset("city.jpeg"), remove_before: true)

      click_button "Update group"

      expect(page).to have_content("Group successfully updated")
      expect(page).to have_content("My super duper group")
      expect(page).to have_content("We are awesome")
    end
  end
end
