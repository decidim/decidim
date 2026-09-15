# frozen_string_literal: true

require "spec_helper"

describe "Conference admin accesses admin sections" do
  include_context "when conference admin administrating a conference"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.conferences_path

    within("tr", text: translated(conference.title)) do
      find("button[data-controller='dropdown']").click
      click_on "Edit"
    end
  end

  it "can access all sections" do
    within_admin_sidebar_menu do
      expect(page).to have_text("About this conference")
      expect(page).to have_text("Components")
      expect(page).to have_text("Attachments")
      expect(page).to have_text("Media links")
      expect(page).to have_text("Partners")
      expect(page).to have_text("Speakers")
      expect(page).to have_text("Registrations")
      expect(page).to have_text("Registration types")
      expect(page).to have_text("Invites")
      expect(page).to have_text("Certificate of attendance")
      expect(page).to have_text("Conference admins")
      expect(page).to have_text("Moderations")
    end
  end
end
