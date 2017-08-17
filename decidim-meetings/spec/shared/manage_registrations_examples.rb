# frozen_string_literal: true

shared_examples "manage registrations" do
  it "enable and configure registrations" do
    within find("tr", text: translated(meeting.title)) do
      page.find("a.action-icon--registrations").click
    end

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

    within ".callout-wrapper" do
      expect(page).to have_content("Meeting registrations settings successfully saved")
    end
  end

  context "when registrations are enabled" do
    let!(:meeting) { create :meeting, scope: scope, feature: current_feature, registrations_enabled: true }
    let!(:registrations) { create_list :registration, 10, meeting: meeting }

    context "and a few registrations have been created" do
      it "can verify the number of registrations" do
        within find("tr", text: translated(meeting.title)) do
          page.find("a.action-icon--registrations").click
        end

        expect(page).to have_content("#{registrations.length} registrations")
      end
    end
  end

  # frozen_string_literal: true

  context "export registrations" do
    let!(:registrations) { create_list :registration, 10, meeting: meeting }

    it "exports a CSV" do
      within find("tr", text: translated(meeting.title)) do
        page.find("a.action-icon--registrations").click
      end

      find(".exports.dropdown").click

      click_link "Registrations as CSV"

      expect(page.response_headers["Content-Type"]).to eq("text/csv")
      expect(page.response_headers["Content-Disposition"]).to match(/attachment; filename=.*\.csv/)
    end

    it "exports a JSON" do
      within find("tr", text: translated(meeting.title)) do
        page.find("a.action-icon--registrations").click
      end

      find(".exports.dropdown").click

      click_link "Registrations as JSON"

      expect(page.response_headers["Content-Type"]).to eq("text/json")
      expect(page.response_headers["Content-Disposition"]).to match(/attachment; filename=.*\.json/)
    end
  end
end
