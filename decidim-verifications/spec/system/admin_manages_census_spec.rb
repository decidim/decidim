# frozen_string_literal: true

require "spec_helper"
describe "Admin manages census" do
  let!(:organization) { create(:organization, available_authorizations:) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:available_authorizations) { %w(id_documents postal_letter csv_census dummy_authorization_handler another_dummy_authorization_handler sms) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user

    visit decidim_admin.root_path
    click_on "Participants"
    within_admin_sidebar_menu do
      click_on "Authorizations"
    end
  end

  context "when authorization handlers are available" do
    it "displays the menu entries" do
      within ".sidebar-menu" do
        expect(page).to have_content("Identity documents")
        expect(page).to have_content("Code by postal letter")
        expect(page).to have_content("Organization's census")
      end
    end
  end

  context "when adding a new census record" do
    before do
      within ".sidebar-menu" do
        click_on "Organization's census"
      end
    end

    it "displays a successful message" do
      expect(page).to have_content("Current census data")
      expect(page).to have_content("There are no census data.")
      expect(page).to have_content("Import CSV")
      expect(page).to have_content("Add new record")

      click_on "Add new record"
      expect(page).to have_content("Add new census record")
      expect(page).to have_content("Email")

      fill_in "Email", with: "this_email_does_not_exist@example.org"
      expect(page).to have_content("Save")
      click_on "Save"

      expect(page).to have_content("Successfully added census data record.")
      expect(page).to have_css(".table-list tbody tr", count: 1)
    end

    context "when edit a census record" do
      before do
        click_on "Add new record"
        fill_in "Email", with: "this_email_does_not_exist@example.org"
        click_on "Save"
      end

      it "edits the added census record" do
        expect(page).to have_content("Created At")
        expect(page).to have_content("User verification")
        expect(page).to have_content("Actions")
        expect(page).to have_content("this_email_does_not_exist@example.org")

        click_on "Edit", match: :first
        expect(page).to have_content("Edit census record")
        fill_in "Email", with: "this_edit_email_exist@example.org"
        click_on "Save"
        expect(page).to have_content("Successfully updated census data record.")
        expect(page).to have_no_content("this_email_does_not_exist@example.org")
        expect(page).to have_content("this_edit_email_exist@example.org")
      end

      it "deletes the added census record" do
        accept_confirm { click_on "Destroy", match: :first }
        expect(page).to have_content("Census data record have been deleted.")
        expect(page).to have_content("There are no census data. Use Import CSV to import a CSV file.")
      end
    end
  end
end
