# frozen_string_literal: true

require "spec_helper"

describe "Organizations", type: :system do
  let(:admin) { create(:admin) }

  context "when an admin authenticated" do
    before do
      login_as admin, scope: :admin
      visit decidim_system.root_path
    end

    describe "creating an organization" do
      before do
        click_link "Organizations"
        click_link "New"
      end

      it "creates a new organization" do
        fill_in "Name", with: "Citizen Corp"
        fill_in "Host", with: "www.citizen.corp"
        fill_in "Secondary hosts", with: "foo.citizen.corp\n\rbar.citizen.corp"
        fill_in "Reference prefix", with: "CCORP"
        fill_in "Organization admin name", with: "City Mayor"
        fill_in "Organization admin email", with: "mayor@citizen.corp"
        check "organization_available_locales_en"
        choose "organization_default_locale_en"
        choose "Allow participants to register and login"
        check "Example authorization (Direct)"
        click_button "Create organization & invite admin"

        expect(page).to have_css("div.flash.success")
        expect(page).to have_content("Citizen Corp")
      end

      context "with invalid data" do
        it "doesn't create an organization" do
          fill_in "Name", with: "Bad"
          click_button "Create organization & invite admin"

          expect(page).to have_content("There's an error in this field")
        end
      end
    end

    describe "showing an organization with different locale than user" do
      let!(:organization) do
        create(:organization, name: "Citizen Corp", default_locale: :es, available_locales: ["es"], description: { es: "Un texto largo" })
      end

      before do
        click_link "Organizations"
        within "table tbody" do
          first("tr").click_link "Citizen Corp"
        end
      end

      it "shows the organization data" do
        expect(page).to have_content("Citizen Corp")
        expect(page).to have_content("Un texto largo")
      end
    end

    describe "editing an organization" do
      let!(:organization) { create(:organization, name: "Citizen Corp") }

      before do
        click_link "Organizations"
        within "table tbody" do
          first("tr").click_link "Edit"
        end
      end

      it "edits the data" do
        fill_in "Name", with: "Citizens Rule!"
        fill_in "Host", with: "www.foo.org"
        fill_in "Secondary hosts", with: "foobar.citizen.corp\n\rbar.citizen.corp"
        choose "Don't allow participants to register, but allow existing participants to login"
        check "Example authorization (Direct)"

        check "organization_omniauth_settings_facebook_enabled"
        fill_in "organization_omniauth_settings_facebook_app_id", with: "facebook-app-id"
        fill_in "organization_omniauth_settings_facebook_app_secret", with: "facebook-app-secret"

        click_button "Save"

        expect(page).to have_css("div.flash.success")
        expect(page).to have_content("Citizens Rule!")
      end
    end
  end
end
