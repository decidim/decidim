# frozen_string_literal: true

def visit_registrations_attendees_page
  within "tr", text: translated(meeting.title) do
    find("button[data-component='dropdown']").click
    click_on "Registrations"
  end
  click_on "View registrations"
end

shared_examples "manage registrations attendees" do
  context "when registration code is enabled and registrations enabled for the meeting" do
    let!(:meeting) { create(:meeting, :published, scope:, component: current_component, registrations_enabled: true) }

    before do
      meeting.component.update!(settings: { registration_code_enabled: true })
    end

    context "when validating registration codes" do
      let!(:registration) { create(:registration, meeting:, code: "QW12ER34") }

      before do
        visit_registrations_attendees_page
      end

      it "shows the registration as not attended" do
        within "tr", text: registration.user.email do
          expect(page).to have_content "Not attended"
        end
      end

      it "can validate a valid registration code" do
        within ".validate_meeting_registration_code" do
          fill_in :validate_registration_code_code, with: "QW12ER34"
          click_on "Validate"
        end

        expect(page).to have_admin_callout("Registration code successfully validated")
        within "tr", text: registration.user.email do
          expect(page).to have_content "Attended"
        end
        expect(registration.reload).to be_validated
      end

      it "cannot validate an invalid registration code" do
        within ".validate_meeting_registration_code" do
          fill_in :validate_registration_code_code, with: "NOT-GOOD"
          click_on "Validate"
        end

        expect(page).to have_admin_callout("This registration code is invalid")
      end
    end

    context "when marking users as attendees" do
      let!(:registration) { create(:registration, meeting:) }

      before do
        visit_registrations_attendees_page
      end

      it "can mark user as attendee" do
        within "tr", text: registration.user.email do
          expect(page).to have_content "Not attended"
          find("button[data-component='dropdown']").click
          click_on "Mark as attendee"
        end

        expect(page).to have_admin_callout("Registration marked as attended successfully")

        within "tr", text: registration.user.email do
          expect(page).to have_content "Attended"
        end
        expect(registration.reload).to be_validated
      end
    end

    context "when validating QR codes" do
      let!(:registration) { create(:registration, meeting:) }

      it "can mark the user as attendee following the QR code short link url" do
        visit registration.validation_code_short_link.short_url

        expect(page).to have_admin_callout("Registration marked as attended successfully")
        within "tr", text: registration.user.email do
          expect(page).to have_content "Attended"
        end

        expect(registration.reload).to be_validated
      end
    end
  end
end
