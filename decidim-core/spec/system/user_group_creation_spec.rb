# frozen_string_literal: true

require "spec_helper"

describe "User group creation" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.profile_path(user.nickname)
  end

  it "creates a user group for the current user" do
    click_on "Create group"

    fill_in "Name", with: "My super user group"
    fill_in "Nickname", with: "my_usergroup"
    fill_in "Email", with: "user_group@decidim.org"
    fill_in "Document number", with: "12345678X"
    fill_in "Phone", with: "12345678"
    fill_in "About", with: "This is us."

    dynamically_attach_file(:group_avatar, Decidim::Dev.asset("avatar.jpg"))

    click_on "Create group"

    expect(page).to have_content("My super user group")
    expect(page).to have_content("@my_usergroup")
    expect(page).to have_content("This is us.")

    click_on "Members"

    within "a.profile__user" do
      expect(page).to have_content(user.name)
    end
  end

  context "when nickname has invalid format" do
    it "shows validation error in the form instead of raising exception" do
      click_on "Create group"

      fill_in "Name", with: "Valid Group Name"
      fill_in "Nickname", with: "Invalid Nickname"
      fill_in "Email", with: "user_group@decidim.org"
      fill_in "Document number", with: "12345678X"
      fill_in "Phone", with: "12345678"

      click_on "Create group"

      expect(page).to have_content("There was a problem creating the group")
      expect(page).to have_css("small.form-error.is-visible", text: "is invalid")
      expect(page).to have_css(".is-invalid-input#group_nickname")
    end
  end

  context "when name has invalid format" do
    it "shows validation error in the form instead of raising exception" do
      click_on "Create group"

      fill_in "Name", with: "<Invalid Name>"
      fill_in "Nickname", with: "valid_nickname"
      fill_in "Email", with: "user_group@decidim.org"
      fill_in "Document number", with: "12345678X"
      fill_in "Phone", with: "12345678"

      click_on "Create group"

      expect(page).to have_content("There was a problem creating the group")
      expect(page).to have_css("small.form-error.is-visible", text: "is invalid")
      expect(page).to have_css(".is-invalid-input#group_name")
    end
  end
end
