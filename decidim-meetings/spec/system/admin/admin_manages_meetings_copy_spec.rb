# frozen_string_literal: true

require "spec_helper"

describe "Admin copies meetings" do
  let(:manifest_name) { "meetings" }
  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:service_titles) { ["This is the first service", "This is the second service"] }
  let!(:meeting) { create(:meeting, type_of_meeting, :published, taxonomies:, services: [], component: current_component) }
  let(:base_date) { Time.new.utc }
  let(:meeting_start_date) { base_date.strftime("%d/%m/%Y") }
  let(:meeting_start_time) { base_date.utc.strftime("%H:%M") }
  let(:meeting_end_date) { ((base_date + 2.days) + 1.month).strftime("%d/%m/%Y") }
  let(:meeting_end_time) { (base_date + 4.hours).strftime("%H:%M") }
  let(:taxonomies) { [taxonomy] }

  include_context "when managing a component as an admin"

  before do
    visit current_path
  end

  context "when online" do
    let(:type_of_meeting) { :online }

    it "creates a new Online meeting", :slow do
      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        find("button[data-component='dropdown']").click
        click_on "Duplicate"
      end

      fill_in_i18n(
        :meeting_title,
        "#meeting-title-tabs",
        en: "My duplicate meeting",
        es: "Mi meeting duplicado",
        ca: "El meu meeting duplicat"
      )
      fill_in_i18n(
        :meeting_location_hints,
        "#meeting-location_hints-tabs",
        en: "Location hints",
        es: "Location hints",
        ca: "Location hints"
      )
      fill_in_i18n_editor(
        :meeting_description,
        "#meeting-description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      fill_in :meeting_online_meeting_url, with: "https://google.com"

      fill_in_datepicker :meeting_start_time_date, with: meeting_start_date
      fill_in_timepicker :meeting_start_time_time, with: meeting_start_time
      fill_in_datepicker :meeting_end_time_date, with: meeting_end_date
      fill_in_timepicker :meeting_end_time_time, with: meeting_end_time

      within ".copy_meetings" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My duplicate meeting")
      end
    end
  end

  context "when hybrid" do
    let(:type_of_meeting) { :hybrid }

    before do
      stub_geocoding(address, [latitude, longitude])
    end

    it "creates a new hybrid meeting", :slow do
      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        find("button[data-component='dropdown']").click
        click_on "Duplicate"
      end

      fill_in_i18n(
        :meeting_title,
        "#meeting-title-tabs",
        en: "My duplicate meeting",
        es: "Mi meeting duplicado",
        ca: "El meu meeting duplicat"
      )
      fill_in_i18n(
        :meeting_location,
        "#meeting-location-tabs",
        en: "Location",
        es: "Location",
        ca: "Location"
      )
      fill_in_i18n(
        :meeting_location_hints,
        "#meeting-location_hints-tabs",
        en: "Location hints",
        es: "Location hints",
        ca: "Location hints"
      )
      fill_in_i18n_editor(
        :meeting_description,
        "#meeting-description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      fill_in_geocoding :meeting_address, with: address
      fill_in :meeting_online_meeting_url, with: "https://google.com"

      fill_in_datepicker :meeting_start_time_date, with: meeting_start_date
      fill_in_timepicker :meeting_start_time_time, with: meeting_start_time
      fill_in_datepicker :meeting_end_time_date, with: meeting_end_date
      fill_in_timepicker :meeting_end_time_time, with: meeting_end_time

      within ".copy_meetings" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My duplicate meeting")
      end
    end
  end

  context "when in person" do
    let(:type_of_meeting) { :in_person }

    before do
      stub_geocoding(address, [latitude, longitude])
    end

    it "creates a new In person meeting", :slow do
      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        find("button[data-component='dropdown']").click
        click_on "Duplicate"
      end

      fill_in_i18n(
        :meeting_title,
        "#meeting-title-tabs",
        en: "My duplicate meeting",
        es: "Mi meeting duplicado",
        ca: "El meu meeting duplicat"
      )
      fill_in_i18n(
        :meeting_location,
        "#meeting-location-tabs",
        en: "Location",
        es: "Location",
        ca: "Location"
      )
      fill_in_i18n(
        :meeting_location_hints,
        "#meeting-location_hints-tabs",
        en: "Location hints",
        es: "Location hints",
        ca: "Location hints"
      )
      fill_in_i18n_editor(
        :meeting_description,
        "#meeting-description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )

      fill_in_geocoding :meeting_address, with: address

      fill_in_datepicker :meeting_start_time_date, with: meeting_start_date
      fill_in_timepicker :meeting_start_time_time, with: meeting_start_time
      fill_in_datepicker :meeting_end_time_date, with: meeting_end_date
      fill_in_timepicker :meeting_end_time_time, with: meeting_end_time

      within ".copy_meetings" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My duplicate meeting")
      end
    end
  end
end
