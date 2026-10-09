# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference invites" do
  include_context "when admin administrating a conference"

  let!(:registration_type) { create(:registration_type, conference:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def visit_invites_page
    visit decidim_admin_conferences.conference_conference_invites_path(conference_slug: conference.slug)
  end

  context "when the conference registrations are enabled" do
    it "shows the list of invites" do
      invite = create(:conference_invite, conference:, registration_type:)

      visit_invites_page

      within "#conference-invites table" do
        expect(page).to have_text(invite.user.name)
        expect(page).to have_text(invite.user.email)
        expect(page).to have_text(translated(registration_type.title))
      end
    end

    it "invites a non existing participant" do
      visit_invites_page
      click_on "Invite participant"

      expect(page).to have_current_path(
        decidim_admin_conferences.new_conference_conference_invite_path(conference_slug: conference.slug)
      )

      within "form.new_conference_registration_invite" do
        choose "Non existing participant"
        fill_in :conference_registration_invite_name, with: "John Doe"
        fill_in :conference_registration_invite_email, with: "jdoe@example.org"
        select translated(registration_type.title), from: :conference_registration_invite_registration_type_id

        find("*[type=submit]").click
      end

      expect(page).to have_callout("Participant successfully invited to join the conference.")
      expect(page).to have_current_path(
        decidim_admin_conferences.conference_conference_invites_path(conference_slug: conference.slug)
      )

      within "#conference-invites table" do
        expect(page).to have_text("John Doe")
        expect(page).to have_text("jdoe@example.org")
      end
    end

    it "invites an existing participant" do
      existing_user = create(:user, :confirmed, organization:)

      visit_invites_page
      click_on "Invite participant"

      within "form.new_conference_registration_invite" do
        choose "Existing participant"
        autocomplete_select "#{existing_user.name} (@#{existing_user.nickname})", from: :user_id
        select translated(registration_type.title), from: :conference_registration_invite_registration_type_id

        find("*[type=submit]").click
      end

      expect(page).to have_callout("Participant successfully invited to join the conference.")

      within "#conference-invites table" do
        expect(page).to have_text(existing_user.name)
        expect(page).to have_text(existing_user.email)
      end
    end

    context "when the form is invalid" do
      it "shows an error message", driver: :rack_test do
        visit_invites_page
        click_on "Invite participant"

        within "form.new_conference_registration_invite" do
          choose "Non existing participant"

          find("*[type=submit]").click
        end

        expect(page).to have_callout("There was a problem inviting the participant to join the conference.")
        expect(page).to have_current_path(
          decidim_admin_conferences.conference_conference_invites_path(conference_slug: conference.slug)
        )
      end
    end
  end

  context "when the conference registrations are disabled" do
    let!(:conference) { create(:conference, organization:, registrations_enabled: false) }

    it "cannot invite participants" do
      visit_invites_page

      expect(page).to have_css("#conference-invites a.disabled", text: "Invite participant")
      expect(page).to have_no_css("#conference-invites a:not(.disabled)", text: "Invite participant")
    end
  end
end
