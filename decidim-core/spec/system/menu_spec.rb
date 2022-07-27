# frozen_string_literal: true

require "spec_helper"

describe "Menu", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  matcher :have_selected_option do |expected|
    match do |page|
      page.has_selector?(".main-nav__link--active", count: 1) &&
        page.has_selector?(".main-nav__link--active", text: expected)
    end
  end

  it "renders the default main menu" do
    within ".main-nav" do
      expect(page).to \
        have_selector("li", count: 3) &
        have_link("Home", href: "/") &
        have_link("Initiatives", href: "/initiatives") &
        have_link("Help", href: "/pages")
    end
  end

  it "selects the correct default active option" do
    within ".main-nav" do
      expect(page).to have_selected_option("Home")
    end
  end

  context "when clicking on a menu entry" do
    before do
      click_link "Help"
    end

    it "switches the active option" do
      expect(page).to have_selected_option("Help")
    end

    context "and clicking on a subpage of that entry" do
      before do
        page = create(:static_page, organization:)

        visit current_path

        click_link page.title["en"]
      end

      it "preserves the active option" do
        expect(page).to have_selected_option("Help")
      end
    end
  end

  context "with a user logged in and multiple languages" do
    let!(:user) { create :user, :confirmed, organization: }

    before do
      login_as user, scope: :user

      visit decidim.root_path

      within_language_menu do
        click_link "Català"
      end
    end

    after do
      within_language_menu do
        click_link "English"
      end
    end

    it "works with multiple languages" do
      visit decidim.root_path

      within ".main-nav" do
        expect(page).to have_selected_option("Inici")
      end
    end
  end
end
