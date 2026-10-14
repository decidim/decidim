# frozen_string_literal: true

require "spec_helper"

describe "Organizations" do
  let(:admin) { create(:admin, email: "system-admin-with-a-very-long-address@example.org") }
  let(:organization) { create(:organization, name: { ca: "", en: "Citizen Corp", es: "" }) }

  context "when an admin authenticated" do
    before do
      login_as admin, scope: :admin
      visit decidim_system.root_path
    end

    describe "current organizations section" do
      it "keeps a long admin email within the logout area" do
        expect(page).to have_css("span.min-w-0.truncate[title='#{admin.email}']", text: admin.email)
        expect(page).to have_link("Logout")
      end

      it "has a link for creating a new organization" do
        click_on "New organization"
        expect(page).to have_text("New organization")
        expect(page).to have_button("Create organization & invite admin")
      end

      it "has a list of the current organizations" do
        expect(page).to have_text("Citizen Corp")
      end
    end

    describe "admins section" do
      it "has a link for creating a new admin" do
        click_on "New admin"
        expect(page).to have_text("New admin")
        expect(page).to have_button("Create")
      end

      it "has a list of the current admins" do
        expect(page).to have_text(admin.email)
      end
    end
  end
end
