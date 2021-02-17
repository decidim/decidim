# frozen_string_literal: true

require "spec_helper"

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
    let!(:polling_officers) { create_list(:polling_officer, 3, voting: voting) }
    let!(:polling_station) { create(:polling_station, voting: voting) }

    before do
      stub_geocoding(address, [latitude, longitude])
      visit current_path
    end

    context "when listing the polling stations" do
      include_context "with filterable context"
      # Need to override these 2 variables from 'with filterable context'
      # because it does not support nested modules (Votings::PollingStations in this case)
      let(:model_name) { Decidim::Votings::PollingStation.model_name }
      let(:module_name) { "Votings::PollingStations" }

      it "lists all the polling stations for the voting" do
        within "#polling_stations table" do
          expect(page).to have_content(translated(polling_station.title, locale: :en))
          expect(page).to have_content(polling_station.address)
        end
      end

      context "when searching by title" do
        let(:searched_station) { create(:polling_station, voting: voting) }

        it "filters the results as expected" do
          search_by_text(translated(searched_station.title))
          expect(page).to have_content(translated(searched_station.title))
          expect(page).not_to have_content(translated(polling_station.title))
        end
      end

      context "when searching by president name" do
        let(:searched_station) { create(:polling_station, voting: voting) }
        let(:president) { create(:polling_officer, voting: voting, presided_polling_station: searched_station) }

        it "filters the results as expected" do
          search_by_text(president.name)
          expect(page).to have_content(translated(searched_station.title))
          expect(page).not_to have_content(translated(polling_station.title))
        end
      end

      context "when searching by manager email" do
        let(:searched_station) { create(:polling_station, voting: voting) }
        let(:manager) { create(:polling_officer, voting: voting, managed_polling_station: searched_station) }

        it "filters the results as expected" do
          search_by_text(manager.email)
          expect(page).to have_content(translated(searched_station.title))
          expect(page).not_to have_content(translated(polling_station.title))
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

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#polling_stations table" do
        expect(page).to have_text("Polling station")
        expect(page).to have_text(polling_officers.first.name)
      end
    end

    it "can delete a polliong station from a voting" do
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

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#polling_stations table" do
        expect(page).to have_text("Another polling station")
        expect(page).to have_text(polling_officers.last.name)
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
