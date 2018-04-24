# frozen_string_literal: true

shared_examples "manage minutes" do
  context "when minutes is created" do
    let!(:minutes) { create :minutes, meeting: meeting }

    it "updates the minutes" do
      page.driver.browser.navigate.refresh

      within find("tr", text: translated(meeting.title)) do
        page.click_link "Minutes"
      end

      within ".edit_minutes" do
        check :minutes_visible
        fill_in :minutes_video_url, with: Faker::Internet.url
        fill_in :minutes_audio_url, with: Faker::Internet.url
        fill_in_i18n_editor(
          :minutes_description,
          "#minutes-description-tabs",
          en: "Description text 2",
          es: "Texto descriptivo 2",
          ca: "Text descriptiu 2"
        )
        click_button "Update"
      end

      expect(page).to have_admin_callout("Minutes successfully updated")
    end
  end

  context "when minutes is not created" do
    it "creates the minutes" do
      within find("tr", text: translated(meeting.title)) do
        page.click_link "Minutes"
      end

      within ".new_minutes" do
        fill_in_i18n_editor(
          :minutes_description,
          "#minutes-description-tabs",
          en: "Description text",
          es: "Texto descriptivo",
          ca: "Text descriptiu"
        )
        click_button "Create"
      end
      expect(page).to have_admin_callout("Minutes successfully created")
    end
  end
end
