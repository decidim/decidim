# frozen_string_literal: true

require "spec_helper"

describe "Mobile header" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    driven_by(:iphone)
    switch_to_host(organization.host)
    visit decidim.root_path
    click_on(id: "dc-dialog-accept")
  end

  context "when user view the header" do
    it "has a favicon as the logo" do
      expect(page).to have_css(".main-bar__logo")
    end

    it "includes a clearly visible login access" do
      expect(page).to have_css(".main-bar__links-mobile__login")
    end
  end

  context "when user access to the hamburger menu" do
    before do
      click_on(id: "main-dropdown-summary-mobile")
    end

    it "includes access to the language selector and search bar" do
      within ".menu-bar__main-dropdown__top" do
        expect(page).to have_css(".filter-search")
        expect(page).to have_css("#trigger-dropdown-language-chooser-mobile")
      end
    end
  end

  context "when user login is confirmed" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim.root_path
    end

    it "displays an avatar on the header" do
      expect(page).to have_css(".main-bar__avatar")
    end
  end
end
