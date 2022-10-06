# frozen_string_literal: true

def visit_edit_registrations_page
  within find("tr", text: translated(meeting.title)) do
    page.click_link "Registrations"
  end
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

  context "when registrations are enabled" do
    let!(:meeting) { create :meeting, :published, scope:, component: current_component, registrations_enabled: true }
    let!(:registrations) { create_list :registration, 10, meeting: }

    context "and a few registrations have been created" do
      it "can verify the number of registrations" do
        visit_edit_registrations_page
        expect(page).to have_content("#{registrations.length} registrations")
      end
    end
  end

  context "when exporting registrations", driver: :rack_test do
    let!(:registrations) { create_list :registration, 10, meeting: }

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

  context "when validating registration codes when registration code is enabled" do
    before do
      meeting.component.update!(settings: { registration_code_enabled: true })
    end

    let!(:registration) { create :registration, meeting:, code: "QW12ER34" }

    it "can validate a valid registration code" do
      visit_edit_registrations_page

      within ".validate_meeting_registration_code" do
        fill_in :validate_registration_code_code, with: "QW12ER34"
        click_button "Validate"
      end

      expect(page).to have_admin_callout("Registration code successfully validated")
    end

    it "can't validate an invalid registration code" do
      visit_edit_registrations_page

      within ".validate_meeting_registration_code" do
        fill_in :validate_registration_code_code, with: "NOT-GOOD"
        click_button "Validate"
      end

      expect(page).to have_admin_callout("This registration code is invalid")
    end
  end
end
