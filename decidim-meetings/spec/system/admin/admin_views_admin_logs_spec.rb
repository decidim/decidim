# frozen_string_literal: true

require "spec_helper"

describe "Admin views admin logs" do
  let(:manifest_name) { "meetings" }

  include_context "when managing a component as an admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "meetings" do
    let(:attributes) { attributes_for(:meeting, component: current_component) }
    let(:base_date) { Time.new.utc }
    let(:meeting_start_date) { base_date.strftime("%d/%m/%Y") }
    let(:meeting_start_time) { base_date.utc.strftime("%H:%M") }
    let(:meeting_end_date) { ((base_date + 2.days) + 1.month).strftime("%d/%m/%Y") }
    let(:meeting_end_time) { (base_date + 4.hours).strftime("%H:%M") }
    let!(:meeting) { create(:meeting, :published, scope:, services: [], component: current_component) }
    let(:latitude) { 40.1234 }
    let(:longitude) { 2.1234 }
    let(:address) { attributes[:address] }

    before do
      stub_geocoding(address, [latitude, longitude])
      visit_component_admin
    end

    it "updates a meeting", versioning: true do
      within "tr", text: Decidim::Meetings::MeetingPresenter.new(meeting).title do
        click_on "Edit"
      end

      within ".edit_meeting" do
        fill_in_i18n(:meeting_title, "#meeting-title-tabs", **attributes[:title].except("machine_translations"))

        fill_in_i18n(:meeting_location, "#meeting-location-tabs", **attributes[:location].except("machine_translations"))
        fill_in_i18n(:meeting_location_hints, "#meeting-location_hints-tabs", **attributes[:location_hints].except("machine_translations"))
        fill_in_i18n_editor(:meeting_description, "#meeting-description-tabs", **attributes[:description].except("machine_translations"))

        fill_in :meeting_address, with: address
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end

    it "creates a new meeting", versioning: true do
      click_on "New meeting"
      fill_in_i18n(:meeting_title, "#meeting-title-tabs", **attributes[:title].except("machine_translations"))

      select "In person", from: :meeting_type_of_meeting

      fill_in_i18n(:meeting_location, "#meeting-location-tabs", **attributes[:location].except("machine_translations"))
      fill_in_i18n(:meeting_location_hints, "#meeting-location_hints-tabs", **attributes[:location_hints].except("machine_translations"))
      fill_in_i18n_editor(:meeting_description, "#meeting-description-tabs", **attributes[:description].except("machine_translations"))

      fill_in :meeting_address, with: address

      select "Registration disabled", from: :meeting_registration_type

      fill_in_datepicker :meeting_start_time_date, with: meeting_start_date
      fill_in_timepicker :meeting_start_time_time, with: meeting_start_time
      fill_in_datepicker :meeting_end_time_date, with: meeting_end_date
      fill_in_timepicker :meeting_end_time_time, with: meeting_end_time

      within ".new_meeting" do
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      visit decidim_admin.root_path
      expect { accept_alert }.to raise_error(Capybara::ModalNotFound)
    end
  end
end
