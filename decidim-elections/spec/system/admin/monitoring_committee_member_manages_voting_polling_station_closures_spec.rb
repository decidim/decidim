# frozen_string_literal: true

require "spec_helper"

describe "Monitoring committee member manages voting polling station closures", type: :system do
  include_context "when monitoring committee member manages voting"
  let(:elections_component) { create(:elections_component, participatory_space: voting) }
  let!(:election) { create(:election, :complete, :published, component: elections_component) }
  let!(:polling_station) { create(:polling_station, voting:) }
  let!(:closure) { create(:ps_closure, phase: :complete, signed_at: Time.current, polling_station:, election:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.edit_voting_path(voting)
    click_link "Validate Certificates"
  end

  context "when listing the polling stations" do
    let(:model_name) { polling_station.class.model_name }
    let(:resource_controller) { Decidim::Votings::Admin::MonitoringCommitteePollingStationClosuresController }

    include_context "with filterable context"

    it "lists all the polling stations for the voting" do
      within "#monitoring_committee_polling_station_closures table" do
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
  end

  context "when validating a polling station closure" do
    before do
      within find("tr", text: translated(polling_station.title)) do
        page.find(".action-icon--validate").click
      end
    end

    it "validates the closure" do
      click_button "Validate"

      expect(page).to have_content("correctly")
      expect(page).to have_content(translated(polling_station.title))
      within find("tr", text: translated(polling_station.title)) do
        expect(page).to have_selector(".action-icon--view")
      end
    end
  end
end
