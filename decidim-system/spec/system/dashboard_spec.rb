# frozen_string_literal: true

require "spec_helper"

describe "Organizations" do
  let(:admin) { create(:admin, email: "system@example.org") }
  let(:organization) { create(:organization, name: "Citizen Corp") }

  context "when an admin authenticated" do
    before do
      login_as admin, scope: :admin
      visit decidim_system.root_path
    end

    describe "current organizations section" do
      it "has a list of the current organizations" do
        expect(page).to have_content("Citizen Corp")
      end
    end

    describe "admins section" do
      it "has a link for creating a new admin" do
        click_link "New admin"
        expect(page).to have_content("New admin")
        expect(page).to have_button("Create")
      end

      it "has a list of the current admins" do
        expect(page).to have_content("system@example.org")
      end
    end
  end
end
