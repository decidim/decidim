# frozen_string_literal: true

require "spec_helper"

describe "Admin copies meetings", type: :system do
  let(:manifest_name) { "meetings" }
  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:service_titles) { ["This is the first service", "This is the second service"] }
  let!(:meeting) { create :meeting, type_of_meeting, :published, scope:, services: [], component: current_component }

  include Decidim::SanitizeHelper
  include_context "when managing a component as an admin"

  before do
    visit current_path
  end

  context "when online" do
    let(:type_of_meeting) { :online }

    it "creates a new Online meeting", :slow do
      within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title) do
        click_link "Duplicate"
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

      page.execute_script("$('#meeting_start_time').focus()")
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "10:00").click
      page.find(".datepicker-dropdown .minute", text: "10:50").click

      page.execute_script("$('#meeting_end_time').focus()")
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "12:00").click
      page.find(".datepicker-dropdown .minute", text: "12:50").click

      within ".copy_meetings" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My duplicate meeting")
      end
    end
  end

  context "when hybrid", serves_map: true, serves_geocoding_autocomplete: true do
    let(:type_of_meeting) { :hybrid }

    before do
      stub_geocoding(address, [latitude, longitude])
    end

    it "creates a new hybrid meeting", :slow, :serves_geocoding_autocomplete do
      within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title) do
        click_link "Duplicate"
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

      page.execute_script("$('#meeting_start_time').focus()")
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "10:00").click
      page.find(".datepicker-dropdown .minute", text: "10:50").click

      page.execute_script("$('#meeting_end_time').focus()")
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "12:00").click
      page.find(".datepicker-dropdown .minute", text: "12:50").click

      within ".copy_meetings" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My duplicate meeting")
      end
    end
  end

  context "when in person", serves_map: true, serves_geocoding_autocomplete: true do
    let(:type_of_meeting) { :in_person }

    before do
      stub_geocoding(address, [latitude, longitude])
    end

    it "creates a new In person meeting", :slow, :serves_geocoding_autocomplete do
      within find("tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title) do
        click_link "Duplicate"
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

      page.execute_script("$('#meeting_start_time').focus()")
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "10:00").click
      page.find(".datepicker-dropdown .minute", text: "10:50").click

      page.execute_script("$('#meeting_end_time').focus()")
      page.find(".datepicker-dropdown .day:not(.new)", text: "12").click
      page.find(".datepicker-dropdown .hour", text: "12:00").click
      page.find(".datepicker-dropdown .minute", text: "12:50").click

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
