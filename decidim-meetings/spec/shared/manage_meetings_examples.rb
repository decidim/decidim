# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "manage meetings" do
  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  before do
    Geocoder::Lookup::Test.add_stub(address, [
      { 'latitude' => latitude, 'longitude' => longitude }
    ])
  end

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
      fill_in :meeting_address, with: address

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My new title")
    end
  end

  context "previewing meetings" do
    it "allows the user to preview the meeting" do
      new_window = window_opened_by { click_link translated(meeting.title) }

      within_window new_window do
        expect(current_path).to eq decidim_meetings.meeting_path(id: meeting.id, participatory_process_id: participatory_process.id, feature_id: current_feature.id)
        expect(page).to have_content(translated(meeting.title))
      end
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
        :meeting_location,
        "#location-tabs",
        en: "Location",
        es: "Location",
        ca: "Location"
      )
      fill_in_i18n(
        :meeting_location_hints,
        "#location_hints-tabs",
        en: "Location hints",
        es: "Location hints",
        ca: "Location hints"
      )
      fill_in_i18n_editor(
        :meeting_description,
        "#description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      fill_in :meeting_address, with: address
      fill_in :meeting_start_time, with: 1.day.from_now
      fill_in :meeting_end_time, with: 1.day.from_now + 2.hours

      select scope.name, from: :meeting_decidim_scope_id
      select translated(category.name), from: :meeting_decidim_category_id

      find("*[type=submit]").click
    end

    within ".callout-wrapper" do
      expect(page).to have_content("successfully")
    end

    within "table" do
      expect(page).to have_content("My meeting")
    end
  end

  context "deleting a meeting" do
    let!(:meeting2) { create(:meeting, feature: current_feature) }

    before do
      visit current_path
    end

    it "deletes a meeting" do
      within find("tr", text: translated(meeting2.title)) do
        click_link "Delete"
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).not_to have_content(translated(meeting2.title))
      end
    end
  end

  context "when geocoding is disabled" do
    before do
      allow(Decidim).to receive(:geocoder).and_return(nil)
    end

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
        fill_in :meeting_address, with: address

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My new title")
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
          :meeting_location,
          "#location-tabs",
          en: "Location",
          es: "Location",
          ca: "Location"
        )
        fill_in_i18n(
          :meeting_location_hints,
          "#location_hints-tabs",
          en: "Location hints",
          es: "Location hints",
          ca: "Location hints"
        )
        fill_in_i18n_editor(
          :meeting_description,
          "#description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )

        fill_in :meeting_address, with: address
        fill_in :meeting_start_time, with: 1.day.from_now
        fill_in :meeting_end_time, with: 1.day.from_now + 2.hours

        select scope.name, from: :meeting_decidim_scope_id
        select translated(category.name), from: :meeting_decidim_category_id

        find("*[type=submit]").click
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_content("My meeting")
      end
    end
  end

  context "closing a meeting" do
    let(:proposal_feature) do
      create(:feature, manifest_name: :proposals, participatory_process: meeting.feature.participatory_process)
    end
    let!(:proposals) { create_list(:proposal, 3, feature: proposal_feature) }

    it "closes a meeting with a report" do
      within find("tr", text: translated(meeting.title)) do
        click_link "Close"
      end

      within ".edit_close_meeting" do
        fill_in_i18n(
          :close_meeting_closing_report,
          "#closing_report-tabs",
          en: "The meeting was great!",
          es: "El encuentro fue genial",
          ca: "La trobada va ser genial"
        )
        fill_in :close_meeting_attendees_count, with: 12
        fill_in :close_meeting_contributions_count, with: 44
        fill_in :close_meeting_attending_organizations, with: "Neighbours Association, Group of People Complaining About Something and Other People"
        select proposals.first.title, from: :close_meeting_proposal_ids
        click_button "Close"
      end

      within ".callout-wrapper" do
        expect(page).to have_content("Meeting successfully closed")
      end

      within find("tr", text: translated(meeting.title)) do
        within find("td:nth-child(4)") do
          expect(page).to have_content("Yes")
        end
      end
    end

    context "when a meeting has alredy been closed" do
      let!(:meeting) { create(:meeting, :closed, feature: current_feature) }

      it "can update the information" do
        within find("tr", text: translated(meeting.title)) do
          click_link "Close"
        end

        within ".edit_close_meeting" do
          fill_in :close_meeting_attendees_count, with: 22
          click_button "Close"
        end

        within ".callout-wrapper" do
          expect(page).to have_content("Meeting successfully closed")
        end
      end
    end
  end
end
