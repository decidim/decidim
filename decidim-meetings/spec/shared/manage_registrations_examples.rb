# frozen_string_literal: true

def visit_edit_registrations_page
  within "tr", text: translated(meeting.title) do
    page.click_on "Registrations"
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
      click_on "Save"
    end

    expect(page).to have_admin_callout("Meeting registrations settings successfully saved")
  end

  context "when registrations are enabled" do
    let!(:meeting) { create(:meeting, :published, scope:, component: current_component, registrations_enabled: true) }
    let!(:registrations) { create_list(:registration, 10, meeting:) }

    context "and a few registrations have been created" do
      it "can verify the number of registrations" do
        visit_edit_registrations_page
        expect(page).to have_content("#{registrations.length} registrations")
      end
    end
  end

  context "when exporting registrations", driver: :rack_test do
    let!(:registrations) { create_list(:registration, 10, meeting:) }

    it "exports a CSV" do
      visit_edit_registrations_page

      find(".exports").click

      click_on "Registrations as CSV"

      expect(page.response_headers["Content-Type"]).to eq("text/csv")
      expect(page.response_headers["Content-Disposition"]).to match(/attachment; filename=.*\.csv/)
    end

    it "exports a JSON" do
      visit_edit_registrations_page

      find(".exports").click

      click_on "Registrations as JSON"

      expect(page.response_headers["Content-Type"]).to eq("text/json")
      expect(page.response_headers["Content-Disposition"]).to match(/attachment; filename=.*\.json/)
    end
  end
end
