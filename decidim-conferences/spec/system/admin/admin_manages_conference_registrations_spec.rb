# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference registrations" do
  include_context "when admin administrating a conference"

  let!(:registration_type) { create(:registration_type, conference:) }
  let!(:registration) { create(:conference_registration, :unconfirmed, conference:, registration_type:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_conferences.conference_conference_registrations_path(conference)
  end

  it "lists the conference registrations" do
    within "#conference-registrations table" do
      expect(page).to have_text(registration.user.name)
      expect(page).to have_text(registration.user.email)
      expect(page).to have_text(translated(registration_type.title))
      expect(page).to have_text("Pending")
    end
  end

  it "confirms a pending registration" do
    within "tr[data-id='#{registration.id}']" do
      find("button[data-controller='dropdown']").click
      click_on "Confirm"
    end

    expect(page).to have_callout("Conference registration successfully confirmed.")
    expect(registration.reload).to be_confirmed

    within "#conference-registrations table" do
      expect(page).to have_text("Confirmed")
    end
  end

  it "shows the export options" do
    find("a[data-target='export-dropdown']").click

    within "#export-dropdown" do
      expect(page).to have_link("Registrations as CSV")
      expect(page).to have_link("Registrations as JSON")
      expect(page).to have_link("Registrations as Excel")
    end
  end

  context "when the registrations are disabled" do
    before { conference.update!(registrations_enabled: false) }

    it "cannot confirm a registration" do
      within "tr[data-id='#{registration.id}']" do
        find("button[data-controller='dropdown']").click
        click_on "Confirm"
      end

      expect(page).to have_callout("There was a problem confirming this conference registration.")
      expect(registration.reload).not_to be_confirmed
    end
  end
end
