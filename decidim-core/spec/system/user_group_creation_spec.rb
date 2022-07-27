# frozen_string_literal: true

require "spec_helper"

describe "User group creation", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.profile_path(user.nickname)
  end

  it "creates a user group for the current user" do
    click_link "Create group"

    fill_in "Name", with: "My super user group"
    fill_in "Nickname", with: "my_usergroup"
    fill_in "Email", with: "user_group@decidim.org"
    fill_in "Document number", with: "12345678X"
    fill_in "Phone", with: "12345678"
    fill_in "About", with: "This is us."

    dynamically_attach_file(:group_avatar, Decidim::Dev.asset("avatar.jpg"))

    click_button "Create group"

    expect(page).to have_content("My super user group")
    expect(page).to have_content("@my_usergroup")
    expect(page).to have_content("This is us.")

    click_link "Members"

    within ".card--user_group_membership" do
      expect(page).to have_content(user.name)
    end
  end
end
