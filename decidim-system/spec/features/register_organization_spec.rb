# frozen_string_literal: true

require "spec_helper"

describe "Register an organization", type: :feature do
  let(:admin) { create(:admin) }

  context "authenticated admin" do
    before do
      login_as admin, scope: :admin
      visit decidim_system.root_path
    end

    context "managing organizations" do
      before do
        click_link "Organizations"
        click_link "New"
      end

      it "creates a new organization" do
        fill_in "Name", with: "Citizen Corp"
        fill_in "Host", with: "www.citizen.corp"
        fill_in "Organization admin email", with: "mayor@citizen.corp"
        click_button "Create organization & invite admin"

        expect(page).to have_content("Organization created successfully")
        expect(page).to have_content("Citizen Corp")
      end
    end
  end
end
