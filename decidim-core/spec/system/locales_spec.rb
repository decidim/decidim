# frozen_string_literal: true

require "spec_helper"

describe "Locales", type: :system do
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

    it "displays devise messages with the right locale when not authenticated" do
      within_language_menu do
        click_link "Català"
      end

      visit decidim_admin.root_path

      expect(page).to have_content("Has d'iniciar la sessió o registrar-te abans de continuar.")
    end

    it "displays devise messages with the right locale when authentication fails" do
      click_link "Sign In"

      within_language_menu do
        click_link "Català"
      end

      fill_in "session_user_email", with: "toto@example.org"
      fill_in "session_user_password", with: "toto"

      click_button "Iniciar sessió"

      expect(page).to have_content("Email o la contrasenya no són vàlids.")
    end

    context "with a signed in user" do
      let(:user) { create(:user, :confirmed, locale: "ca", organization: organization) }

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
