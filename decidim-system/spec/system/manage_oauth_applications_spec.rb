# frozen_string_literal: true

require "spec_helper"

describe "Manage OAuth applications" do
  include ActionView::Helpers::SanitizeHelper

  let(:admin) { create(:admin) }
  let!(:organization) { create(:organization) }

  before do
    login_as admin, scope: :admin
    visit decidim_system.oauth_applications_path
  end

  it "can create new applications" do
    click_on "New"

    within ".new_oauth_application" do
      fill_in :oauth_application_name, with: "Meta Decidim"
      within "fieldset", text: "Application type" do
        choose "Confidential"
      end
      fill_in :oauth_application_redirect_uri, with: "https://example.org/oauth/decidim"
      select translated(organization.name), from: :oauth_application_decidim_organization_id
      fill_in :oauth_application_organization_name, with: "Ajuntament de Barcelona"
      fill_in :oauth_application_organization_url, with: "https://www.barcelona.cat"
    end

    dynamically_attach_file(:oauth_application_organization_logo, Decidim::Dev.asset("city.jpeg"), front_interface: true)

    within ".new_oauth_application" do
      find("*[type=submit]").click
    end

    expect(page).to have_content("successfully")

    within "table" do
      expect(page).to have_content("Meta Decidim")
    end
  end

  context "when the application type is not selected" do
    it "shows an error message" do
      click_on "New"

      within ".new_oauth_application" do
        fill_in :oauth_application_name, with: "Meta Decidim"
        fill_in :oauth_application_redirect_uri, with: "https://example.org/oauth/decidim"
        select translated(organization.name), from: :oauth_application_decidim_organization_id
        fill_in :oauth_application_organization_name, with: "Ajuntament de Barcelona"
        fill_in :oauth_application_organization_url, with: "https://www.barcelona.cat"
      end

      dynamically_attach_file(:oauth_application_organization_logo, Decidim::Dev.asset("city.jpeg"), front_interface: true)

      within ".new_oauth_application" do
        find("*[type=submit]").click
      end

      expect(page).to have_content("There was a problem creating this application")
      expect(page).to have_content("is not included in the list")
    end
  end

  context "with existing applications" do
    let!(:application) { create(:oauth_application, organization:) }

    before do
      visit current_path
    end

    it "can edit them" do
      within "tr", text: application.name do
        click_on "Edit"
      end

      within ".edit_oauth_application" do
        fill_in :oauth_application_name, with: "Test application"
        find("*[type=submit]").click
      end

      expect(page).to have_content("successfully")

      within "table" do
        expect(page).to have_content("Test application")
      end
    end

    it "can delete them" do
      within "tr", text: application.name do
        accept_confirm { click_on "Delete" }
      end

      expect(page).to have_content("successfully")

      within "table" do
        expect(page).to have_no_content(application.name)
      end
    end

    it "view their data" do
      click_on application.name

      expect(page).to have_content(application.uid)
      expect(page).to have_content(application.secret)
    end
  end
end
