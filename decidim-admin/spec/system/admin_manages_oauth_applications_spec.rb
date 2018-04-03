# frozen_string_literal: true

require "spec_helper"

describe "Manage OAuth applications", type: :system do
  include ActionView::Helpers::SanitizeHelper

  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "OAuth applications"
  end

  it "can create new applications" do
    find(".new").click

    within ".new_oauth_application" do
      fill_in :oauth_application_name, with: "Meta Decidim"
      fill_in :oauth_application_redirect_uri, with: "https://example.org/oauth/decidim"
      fill_in :oauth_application_organization_name, with: "Ajuntament de Barcelona"
      fill_in :oauth_application_organization_url, with: "https://www.barcelona.cat"
      attach_file "Organization logo", Decidim::Dev.asset("city.jpeg")

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("Meta Decidim")
    end
  end

  context "with existing applications" do
    let!(:application) { create(:oauth_application, organization: organization) }

    before do
      visit current_path
    end

    it "can edit them" do
      within find("tr", text: application.name) do
        click_link "Edit"
      end

      within ".edit_oauth_application" do
        fill_in :oauth_application_name, with: "Test application"
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("Test application")
      end
    end

    it "can destroy them" do
      within find("tr", text: application.name) do
        accept_confirm { click_link "Destroy" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(application.name)
      end
    end

    it "view their data" do
      click_link application.name

      expect(page).to have_content(application.uid)
      expect(page).to have_content(application.secret)
    end
  end
end
