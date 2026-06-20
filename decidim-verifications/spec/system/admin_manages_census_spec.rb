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
        expect(page).to have_text("Identity documents")
        expect(page).to have_text("Code by postal letter")
        expect(page).to have_text("Organization's census")
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
      expect(page).to have_text("Current census data")
      expect(page).to have_text("There are no census data.")
      expect(page).to have_text("Import CSV")
      expect(page).to have_text("Add new record")

      click_on "Add new record"
      expect(page).to have_text("Add new census record")
      expect(page).to have_text("Email")

      fill_in "Email", with: "this_email_does_not_exist@example.org"
      expect(page).to have_text("Save")
      click_on "Save"

      expect(page).to have_text("Successfully added census data record.")
      expect(page).to have_css(".table-list tbody tr", count: 1)
    end

    context "when edit a census record" do
      before do
        click_on "Add new record"
        fill_in "Email", with: "this_email_does_not_exist@example.org"
        click_on "Save"
      end

      it "edits the added census record" do
        expect(page).to have_text("Created At")
        expect(page).to have_text("User authorized?")
        expect(page).to have_text("Actions")
        expect(page).to have_text("this_email_does_not_exist@example.org")

        within "tr", text: "this_email_does_not_exist@example.org" do
          find("button[data-controller='dropdown']").click
          click_on "Edit"
        end

        expect(page).to have_text("Edit census record")
        fill_in "Email", with: "this_edit_email_exist@example.org"
        click_on "Save"
        expect(page).to have_text("Successfully updated census data record.")
        expect(page).to have_no_text("this_email_does_not_exist@example.org")
        expect(page).to have_text("this_edit_email_exist@example.org")
      end

      it "deletes the added census record" do
        within "tr", text: "this_email_does_not_exist@example.org" do
          find("button[data-controller='dropdown']").click
          accept_confirm { click_on "Destroy" }
        end
        expect(page).to have_text("Census data record have been deleted.")
        expect(page).to have_text("There are no census data. Use Import CSV to import a CSV file.")
      end
    end

    context "when import census data" do
      before do
        click_on "Import CSV", match: :first
      end

      it "imports a csv file" do
        expect(page).to have_text("Import census data")
        expect(page).to have_text("Upload a new census")
        expect(page).to have_text("Must be a file in CSV format with only one column with the email address")

        dynamically_attach_file(:census_data_file, Decidim::Dev.asset("valid_emails.csv"))
        click_on "Upload file"
        expect(page).to have_text("Successfully imported")
        expect(page).to have_css(".table-list tbody tr", count: 25)
        within "[data-pagination]" do
          page.find("details", text: "25")
          expect(page).to have_text("Results per page")
          click_on "Next"
        end
        expect(page).to have_text("Current census data")
        expect(page).to have_css(".table-list tbody tr", count: 2)
      end
    end
  end
end
