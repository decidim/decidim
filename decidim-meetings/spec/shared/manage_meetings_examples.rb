# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage meetings" do
  it "updates a meeting" do
    within find("tr", text: translated(meeting.title)) do
      click_link "Edit"
    end

    within ".edit_meeting" do
      fill_in_i18n(
        :meeting_title,
        "#title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My new title")
    end
  end

  context "previewing meetings" do
    it "allows the user to preview the meeting" do
      click_link translated(meeting.title)

      expect(current_path).to eq decidim_meetings.meeting_path(id: meeting.id, participatory_process_id: participatory_process.id, feature_id: feature.id)
      expect(page).to have_content(translated(meeting.title))
    end
  end

  it "creates a new meeting" do
    find(".actions .new").click

    within ".new_meeting" do
      fill_in_i18n(
        :meeting_title,
        "#title-tabs",
        en: "My meeting",
        es: "Mi meeting",
        ca: "El meu meeting"
      )
      fill_in_i18n(
        :meeting_location_hints,
        "#location_hints-tabs",
        en: "Location hints",
        es: "Location hints",
        ca: "Location hints"
      )
      fill_in_i18n_editor(
        :meeting_short_description,
        "#short_description-tabs",
        en: "Short description",
        es: "Descripción corta",
        ca: "Descripció curta"
      )
      fill_in_i18n_editor(
        :meeting_description,
        "#description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      fill_in :meeting_address, with: "Address"
      fill_in :meeting_start_date, with: 1.day.from_now
      fill_in :meeting_end_date, with: 1.day.from_now + 2.hours

      find("*[type=submit]").click
    end

    within ".flash" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My meeting")
    end
  end

  context "deleting a participatory process" do
    let!(:meeting2) { create(:meeting, feature: current_feature) }

    before do
      visit current_path
    end

    it "deletes a meeting" do
      within find(:tr, text: translated(meeting2.title)) do
        click_link "Delete"
      end

      within ".flash" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to_not have_content(translated(meeting2.title))
      end
    end
  end
end
