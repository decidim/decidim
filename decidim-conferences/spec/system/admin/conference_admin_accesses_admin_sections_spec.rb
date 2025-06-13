# frozen_string_literal: true

require "spec_helper"

describe "Conference admin accesses admin sections" do
  include_context "when conference admin administrating a conference"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.conferences_path

    within("tr", text: translated(conference.title)) do
      find("button[data-component='dropdown']").click
      click_on "Configure"
    end
  end

  it "can access all sections" do
    within_admin_sidebar_menu do
      expect(page).to have_content("About this conference")
      expect(page).to have_content("Components")
      expect(page).to have_content("Attachments")
      expect(page).to have_content("Media links")
      expect(page).to have_content("Partners")
      expect(page).to have_content("Speakers")
      expect(page).to have_content("Registrations")
      expect(page).to have_content("Registration types")
      expect(page).to have_content("Invites")
      expect(page).to have_content("Certificate of attendance")
      expect(page).to have_content("Conference admins")
      expect(page).to have_content("Moderations")
    end
  end
end
