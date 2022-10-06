# frozen_string_literal: true

require "spec_helper"
require "decidim/votings/test/capybara_polling_officers_picker"

describe "Admin manages polling stations", type: :system, serves_geocoding_autocomplete: true do
  let(:address) { "Somewhere over the rainbow" }
  let(:latitude) { 42.123 }
  let(:longitude) { 2.123 }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.edit_voting_path(voting)
    click_link "Polling Stations"
  end

  include_context "when admin managing a voting"

  context "when processing polling stations" do
    let!(:polling_officers) { create_list(:polling_officer, 3, voting:) }
    let!(:polling_station) { create(:polling_station, voting:) }

    before do
      stub_geocoding(address, [latitude, longitude])
      visit current_path
    end

    context "when listing the polling stations" do
      let(:model_name) { polling_station.class.model_name }
      let(:resource_controller) { Decidim::Votings::Admin::PollingStationsController }

      include_context "with filterable context"

      it "lists all the polling stations for the voting" do
        within "#polling_stations table" do
          expect(page).to have_content(translated(polling_station.title, locale: :en))
          expect(page).to have_content(polling_station.address)
        end
      end

      it "has the callout warning of missing officers" do
        expect(page).to have_text("There are Polling Stations without President and/or Managers")
      end

      context "when searching by title" do
        let(:searched_station) { create(:polling_station, voting:) }

        it "filters the results as expected" do
          search_by_text(translated(searched_station.title))
          expect(page).to have_content(translated(searched_station.title))
          expect(page).not_to have_content(translated(polling_station.title))
        end
      end

      context "when searching by president name" do
        let(:searched_station) { create(:polling_station, voting:) }
        let(:president) { create(:polling_officer, voting:, presided_polling_station: searched_station) }

        it "filters the results as expected" do
          search_by_text(president.name)
          expect(page).to have_content(translated(searched_station.title))
          expect(page).not_to have_content(translated(polling_station.title))
        end
      end

      context "when searching by manager email" do
        let(:searched_station) { create(:polling_station, voting:) }
        let(:manager) { create(:polling_officer, voting:, managed_polling_station: searched_station) }

        it "filters the results as expected" do
          search_by_text(manager.email)
          expect(page).to have_content(translated(searched_station.title))
          expect(page).not_to have_content(translated(polling_station.title))
        end
      end

      context "when filtering by assigned/unussigned" do
        let(:polling_station_with_president) { create(:polling_station, voting:) }
        let(:polling_station_with_both) { create(:polling_station, voting:) }
        let!(:polling_station_unassigned) { create(:polling_station, voting:) }

        let!(:president) { create(:polling_officer, voting:, presided_polling_station: polling_station_with_president) }
        let!(:manager) { create(:polling_officer, voting:, managed_polling_station: polling_station_with_both) }
        let!(:other_president) { create(:polling_officer, voting:, presided_polling_station: polling_station_with_both) }

        it_behaves_like "a filtered collection", options: "Officers", filter: "Assigned" do
          let(:in_filter) { translated(polling_station_with_both.title) }
          let(:not_in_filter) { translated(polling_station_with_president.title) }
        end

        it_behaves_like "a filtered collection", options: "Officers", filter: "Not assigned" do
          let(:in_filter) { translated(polling_station_unassigned.title) }
          let(:not_in_filter) { translated(polling_station_with_both.title) }
        end
      end
    end

    it "can add a polling station to a process", :serves_geocoding_autocomplete do
      click_link("New")

      within ".new_polling_station" do
        fill_in_i18n(
          :polling_station_title,
          "#polling_station-title-tabs",
          en: "Polling station",
          es: "Colegio electoral",
          ca: "Col·legi electoral"
        )

        fill_in_geocoding :polling_station_address, with: address

        fill_in_i18n(
          :polling_station_location,
          "#polling_station-location-tabs",
          en: "Location",
          es: "Location",
          ca: "Location"
        )

        fill_in_i18n(
          :polling_station_location_hints,
          "#polling_station-location_hints-tabs",
          en: "Location hints",
          es: "Location hints",
          ca: "Location hints"
        )

        autocomplete_select "#{polling_officers.first.name} (@#{polling_officers.first.nickname})", from: :polling_station_president_id

        polling_officers_pick(select_data_picker(:polling_station_polling_station_managers, multiple: true), polling_officers.last(2))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#polling_stations table" do
        expect(page).to have_text("Polling station")
        expect(page).to have_text(polling_officers.first.name)
        polling_officers.last(2).each do |polling_officer|
          expect(page).to have_text(polling_officer.name)
        end
      end
    end

    it "can delete a polling station from a voting" do
      within find("tr", text: translated(polling_station.title)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      expect(page).to have_no_content(translated(polling_station.title, locale: :en))
    end

    it "can update a polling_station" do
      within "#polling_stations" do
        within find("tr", text: translated(polling_station.title)) do
          click_link "Edit"
        end
      end

      within ".edit_polling_station" do
        fill_in_i18n(
          :polling_station_title,
          "#polling_station-title-tabs",
          en: "Another polling station",
          es: "Otro colegio electoral",
          ca: "Un altre col·legi electoral"
        )
        fill_in :polling_station_address, with: address

        autocomplete_select "#{polling_officers.last.name} (@#{polling_officers.last.nickname})", from: :polling_station_president_id

        polling_officers_pick(select_data_picker(:polling_station_polling_station_managers, multiple: true), polling_officers.first(2))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).not_to have_text("There are Polling Stations without President and/or Managers")

      within "#polling_stations table" do
        expect(page).to have_text("Another polling station")
        expect(page).to have_text(polling_officers.last.name)
        polling_officers.first(2).each do |polling_officer|
          expect(page).to have_text(polling_officer.name)
        end
      end
    end
  end

  context "when using the front-end geocoder", :serves_geocoding_autocomplete do
    before do
      stub_geocoding(address, [latitude, longitude])
    end

    it_behaves_like(
      "a record with front-end geocoding address field",
      Decidim::Votings::PollingStation,
      within_selector: ".new_polling_station",
      address_field: :polling_station_address
    ) do
      let(:geocoded_address_value) { address }
      let(:geocoded_address_coordinates) { [latitude, longitude] }

      before do
        # Prepare the view for submission (other than the address field)
        click_link("New")

        fill_in_i18n(
          :polling_station_title,
          "#polling_station-title-tabs",
          en: "Polling station",
          es: "Colegio electoral",
          ca: "Col·legi electoral"
        )

        fill_in_i18n(
          :polling_station_location,
          "#polling_station-location-tabs",
          en: "Location",
          es: "Location",
          ca: "Location"
        )

        fill_in_i18n(
          :polling_station_location_hints,
          "#polling_station-location_hints-tabs",
          en: "Location hints",
          es: "Location hints",
          ca: "Location hints"
        )
      end
    end
  end
end
