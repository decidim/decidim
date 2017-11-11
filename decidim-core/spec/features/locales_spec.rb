# frozen_string_literal: true

require "spec_helper"

describe "Locales", type: :feature do
  describe "switching locales" do
    let(:organization) { create(:organization, available_locales: %w(en ca)) }

    before do
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    it "changes the locale to the chosen one" do
      within_language_menu do
        click_link "Català"
      end

      expect(page).to have_content("Inici")
    end

    it "only shows the available locales" do
      within_language_menu do
        expect(page).to have_content("Català")
        expect(page).to have_content("English")
        expect(page).to have_no_content("Castellano")
      end
    end

    it "keeps the locale between pages" do
      within_language_menu do
        click_link "Català"
      end

      click_link "Inici"

      expect(page).to have_content("Inici")
    end

    context "with a signed in user" do
      let(:user) { create(:user, :confirmed, locale: "ca") }

      before do
        login_as user, scope: :user
        visit decidim.root_path
      end

      it "uses the user's locale" do
        expect(page).to have_content("Inici")
      end
    end
  end
end
