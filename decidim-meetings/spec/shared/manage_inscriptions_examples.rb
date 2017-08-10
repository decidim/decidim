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
end
