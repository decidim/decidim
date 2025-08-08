# frozen_string_literal: true

require "spec_helper"

describe "Locales" do
  describe "switching locales" do
    let(:organization) { create(:organization, available_locales: %w(en ca)) }

    before do
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    it "changes the locale to the chosen one" do
      within_language_menu do
        click_on "Català"
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
        click_on "Català"
      end

      click_on "Inici", match: :first

      expect(page).to have_content("Inici")
    end

    it "displays devise messages with the right locale when not authenticated" do
      within_language_menu do
        click_on "Català"
      end

      # Prevent flaky spec, where sometimes the language is not changed before the visit
      sleep 2
      visit decidim_admin.root_path

      expect(page).to have_content("Cal iniciar sessió o crear un compte abans de continuar.")
    end

    it "displays devise messages with the right locale when authentication fails" do
      click_on "Log in", match: :first

      within_language_menu do
        click_on "Català"
      end

      within ".new_user" do
        fill_in "session_user_email", with: "toto@example.org"
        fill_in "session_user_password", with: "toto"
        click_on "Entra"
      end

      expect(page).to have_content("Adreça de correu electrònic o la contrasenya no són vàlids.")
    end

    context "with a signed in user" do
      let(:user) { create(:user, :confirmed, locale: "ca", organization:) }

      before do
        login_as user, scope: :user

        # Prevent flaky spec, where sometimes the language is not changed before the visit
        sleep 2
        visit decidim.root_path
      end

      it "uses the user's locale" do
        expect(page).to have_content("Inici")
      end
    end
  end
end
