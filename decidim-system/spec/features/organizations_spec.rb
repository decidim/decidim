# frozen_string_literal: true

require "spec_helper"

describe "Organizations", type: :feature do
  let(:admin) { create(:admin) }

  context "authenticated admin" do
    before do
      login_as admin, scope: :admin
      visit decidim_system.root_path
    end

    context "creating an organization" do
      before do
        click_link "Organizations"
        click_link "New"
      end

      it "creates a new organization" do
        fill_in "Name", with: "Citizen Corp"
        fill_in "Host", with: "www.citizen.corp"
        fill_in "Organization admin name", with: "City Mayor"
        fill_in "Organization admin email", with: "mayor@citizen.corp"
        check "organization_available_locales_en"
        choose "organization_default_locale_en"
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

    context "editing an organization" do
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
        click_button "Save"

        expect(page).to have_css("div.flash.success")
        expect(page).to have_content("Citizens Rule!")
      end
    end
  end
end
