# frozen_string_literal: true

require "spec_helper"

describe "Conference admin accesses admin sections", type: :system do
  include_context "when conference admin administrating a conference"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.conferences_path

    click_link "Configure"
  end

  it "can access all sections" do
    within ".secondary-nav" do
      expect(page).to have_content("Info")
      expect(page).to have_content("Components")
      expect(page).to have_content("Categories")
      expect(page).to have_content("Attachments")
      expect(page).to have_content("Folders")
      expect(page).to have_content("Files")
      expect(page).to have_content("Speakers")
      expect(page).to have_content("Registrations")
      expect(page).to have_content("Conference admins")
      expect(page).to have_content("Moderations")
    end
  end
end
