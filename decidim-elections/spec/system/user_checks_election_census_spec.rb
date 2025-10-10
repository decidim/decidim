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

      expect(page).to have_link(I18n.t("decidim.elections.elections.show.check_census_button"), href: new_census_check_path)
      click_link I18n.t("decidim.elections.elections.show.check_census_button")

      expect(page).to have_current_path(new_census_check_path)

      fill_in I18n.t("decidim.elections.censuses.token_csv_form.email"), with: voter_data["email"]
      fill_in I18n.t("decidim.elections.censuses.token_csv_form.token"), with: voter_data["token"]
      click_button I18n.t("decidim.elections.votes.check_census.access")

      expect(page).to have_current_path(census_check_path)
      expect(page).to have_content(I18n.t("decidim.elections.census_checks.show.title"))
      expect(page).to have_content(I18n.t("decidim.elections.census_checks.show.description"))

      click_link I18n.t("decidim.elections.census_checks.show.exit_button")

      expect(page).to have_current_path(election_path)
    end
  end

  context "when the election is ongoing" do
    let!(:election) { create(:election, :published, :ongoing, :with_token_csv_census, component:) }
    let(:election_path) { Decidim::EngineRouter.main_proxy(component).election_path(election) }

    it "does not display the census check button" do
      visit election_path

      expect(page).to have_no_link(I18n.t("decidim.elections.elections.show.check_census_button"))
    end
  end
end
