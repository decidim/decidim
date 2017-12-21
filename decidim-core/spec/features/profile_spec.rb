# frozen_string_literal: true

require "spec_helper"

describe "Profile", type: :feature do
  let(:user) { create(:user, :confirmed) }

  before do
    switch_to_host(user.organization.host)
  end

  context "when navigating privately" do
    before do
      login_as user, scope: :user
    end

    it "shows the profile page when clicking on the menu" do
      visit decidim.root_path

      within_user_menu do
        find("a", text: "profile").click
      end

      expect(page).to have_title(user.nickname)
    end
  end

  context "when navigating publicly" do
    before do
      visit decidim.profile_path(user.nickname)
    end

    it "shows user name in the header, its nickname and a contact link" do
      expect(page).to have_selector("h1", text: user.name)
      expect(page).to have_content(user.nickname)
      expect(page).to have_link("Contact")
    end
  end
end
