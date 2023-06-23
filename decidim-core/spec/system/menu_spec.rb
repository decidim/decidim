# frozen_string_literal: true

require "spec_helper"

describe "Menu", type: :system do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  context "when clicking on a menu entry" do
    before do
      click_link("Help", match: :first)
    end

    it "switches the active option" do
      expect(page).to have_selector(".menu-bar__breadcrumb-desktop__dropdown-trigger", text: "Help")
    end

    context "and clicking on a subpage of that entry" do
      before do
        page = create(:static_page, organization:)

        visit current_path

        click_link page.title["en"]
      end

      it "preserves the active option" do
        expect(page).to have_selector(".menu-bar__breadcrumb-desktop__dropdown-trigger", text: "Help")
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
  end
end
