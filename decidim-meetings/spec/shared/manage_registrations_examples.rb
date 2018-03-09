# frozen_string_literal: true

def visit_edit_registrations_page
  within find("tr", text: translated(meeting.title)) do
    page.click_link "Registrations"
  end
end

def fill_in_meeting_registration_invite(name:, email:)
  click_link "Invite user"

  within "form.new_meeting_registration_invite" do
    fill_in :meeting_registration_invite_name, with: name
    fill_in :meeting_registration_invite_email, with: email
  end

  click_button "Invite"

  expect(page).to have_content("successfully")
end

shared_examples "manage registrations" do
  it "enable and configure registrations" do
    visit_edit_registrations_page

    within ".edit_meeting_registrations" do
      check :meeting_registrations_enabled
      fill_in :meeting_available_slots, with: 20
      fill_in_i18n_editor(
        :meeting_registration_terms,
        "#meeting-registration_terms-tabs",
        en: "A legal text",
        es: "Un texto legal",
        ca: "Un text legal"
      )
      click_button "Save"
    end

    expect(page).to have_admin_callout("Meeting registrations settings successfully saved")
  end

  context "when registrations are not enabled" do
    it "cannot invite people to join a meeting" do
      visit_edit_registrations_page
      expect(page).to have_selector("a.disabled", text: "INVITE USER")
    end
  end

  context "when registrations are enabled" do
    let!(:meeting) { create :meeting, scope: scope, component: current_component, registrations_enabled: true }
    let!(:registrations) { create_list :registration, 10, meeting: meeting }

    context "and a few registrations have been created" do
      it "can verify the number of registrations" do
        visit_edit_registrations_page
        expect(page).to have_content("#{registrations.length} registrations")
      end
    end

    context "when inviting a unregistered user" do
      it "the invited user sign up into the application and joins the meeting" do
        visit_edit_registrations_page

        perform_enqueued_jobs do
          fill_in_meeting_registration_invite name: "Foo", email: "foo@example.org"
        end

        logout :user

        visit last_email_link

        within "form.new_user" do
          fill_in :user_nickname, with: "caballo_loco"
          fill_in :user_password, with: "123456"
          fill_in :user_password_confirmation, with: "123456"
          find("*[type=submit]").click
        end

        expect(page).to have_content "successfully"

        within ".card.extra" do
          expect(page).to have_css(".button", text: "GOING")
        end
      end
    end

    context "when inviting a registered user" do
      let!(:registered_user) { create(:user, :confirmed, organization: organization) }

      it "the invited user joins the meeting" do
        visit_edit_registrations_page

        perform_enqueued_jobs do
          fill_in_meeting_registration_invite name: registered_user.name, email: registered_user.email
        end

        relogin_as user

        visit last_email_link

        within ".card.extra" do
          expect(page).to have_css(".button", text: "GOING")
        end
      end
    end
  end

  context "export registrations", driver: :rack_test do
    let!(:registrations) { create_list :registration, 10, meeting: meeting }

    it "exports a CSV" do
      visit_edit_registrations_page

      find(".exports.dropdown").click

      click_link "Registrations as CSV"

      expect(page.response_headers["Content-Type"]).to eq("text/csv")
      expect(page.response_headers["Content-Disposition"]).to match(/attachment; filename=.*\.csv/)
    end

    it "exports a JSON" do
      visit_edit_registrations_page

      find(".exports.dropdown").click

      click_link "Registrations as JSON"

      expect(page.response_headers["Content-Type"]).to eq("text/json")
      expect(page.response_headers["Content-Disposition"]).to match(/attachment; filename=.*\.json/)
    end
  end
end
