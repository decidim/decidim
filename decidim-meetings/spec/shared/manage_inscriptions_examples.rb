# frozen_string_literal: true

shared_examples "manage inscriptions" do
  it "enable and configure inscriptions" do
    within find("tr", text: translated(meeting.title)) do
      page.find("a.action-icon--inscriptions").click
    end

    within ".edit_meeting_inscriptions" do
      check :meeting_inscriptions_enabled
      fill_in :meeting_available_slots, with: 20
      fill_in_i18n_editor(
        :meeting_inscription_terms,
        "#meeting-inscription_terms-tabs",
        en: "A legal text",
        es: "Un texto legal",
        ca: "Un text legal"
      )
      click_button "Save"
    end

    within ".callout-wrapper" do
      expect(page).to have_content("Meeting inscriptions settings successfully saved")
    end
  end

  context "when inscriptions are enabled" do
    let!(:meeting) { create :meeting, scope: scope, feature: current_feature, inscriptions_enabled: true }
    let!(:inscriptions) { create_list :inscription, 10, meeting: meeting }

    context "and a few inscriptions have been created" do
      it "can verify the number of inscriptions" do
        within find("tr", text: translated(meeting.title)) do
          page.find("a.action-icon--inscriptions").click
        end

        expect(page).to have_content("#{inscriptions.length} inscriptions")
      end
    end
  end

  # frozen_string_literal: true

  context "export inscriptions" do
    let!(:inscriptions) { create_list :inscription, 10, meeting: meeting }

    it "exports a CSV" do
      within find("tr", text: translated(meeting.title)) do
        page.find("a.action-icon--inscriptions").click
      end

      find(".exports.dropdown").click

      click_link "Inscriptions as CSV"

      expect(page.response_headers["Content-Type"]).to eq("text/csv")
      expect(page.response_headers["Content-Disposition"]).to match(/attachment; filename=.*\.csv/)
    end

    it "exports a JSON" do
      within find("tr", text: translated(meeting.title)) do
        page.find("a.action-icon--inscriptions").click
      end

      find(".exports.dropdown").click

      click_link "Inscriptions as JSON"

      expect(page.response_headers["Content-Type"]).to eq("text/json")
      expect(page.response_headers["Content-Disposition"]).to match(/attachment; filename=.*\.json/)
    end
  end
end
