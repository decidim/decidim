# frozen_string_literal: true

require "spec_helper"

describe "Election census check" do
  let(:component) { create(:elections_component) }
  let(:organization) { component.organization }

  before do
    switch_to_host(organization.host)
  end

  context "when the election is scheduled" do
    let!(:election) { create(:election, :published, :scheduled, :with_token_csv_census, component:) }
    let(:election_path) { Decidim::EngineRouter.main_proxy(component).election_path(election) }
    let(:new_census_check_path) { Decidim::EngineRouter.main_proxy(component).new_election_census_check_path(election) }
    let(:census_check_path) { Decidim::EngineRouter.main_proxy(component).election_census_check_path(election) }
    let(:voter_data) { election.voters.first.data }

    it "allows the user to validate they are in the census" do
      visit election_path

      expect(page).to have_link("Check if I can vote")
      click_link "Check if I can vote"

      expect(page).to have_current_path(new_census_check_path)

      fill_in "Email", with: voter_data["email"]
      fill_in "Token", with: voter_data["token"]
      click_button "Access"

      expect(page).to have_current_path(census_check_path)
      expect(page).to have_content("You can vote in this election")
      expect(page).to have_content("You are included in the census and will be able to vote once the election starts.")

      click_link "Exit"

      expect(page).to have_current_path(election_path)
    end
  end

  context "when the election is ongoing" do
    let!(:election) { create(:election, :published, :ongoing, :with_token_csv_census, component:) }
    let(:election_path) { Decidim::EngineRouter.main_proxy(component).election_path(election) }

    it "does not display the census check button" do
      visit election_path

      expect(page).to have_no_link("Check if I can vote")
    end
  end
end
