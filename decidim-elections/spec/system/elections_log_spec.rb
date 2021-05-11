# frozen_string_literal: true

require "spec_helper"

describe "Elections log", type: :system do
  let(:manifest_name) { "elections" }
  let!(:organization) { create(:organization) }
  let!(:election) { create :election, :bb_test, :created, component: component }

  include_context "with a component" do
    let!(:voting) { create(:voting, :published, organization: organization) }
    let(:participatory_space) { voting }
    let(:organization_traits) { [:secure_context] }
  end

  before do
    VCR.turn_off!
    Decidim::Elections.bulletin_board.reset_test_database
  end

  after do
    VCR.turn_on!
  end

  describe "when voting has only one election" do
    it "redirects to election log" do
      visit decidim_votings.voting_elections_log_path(voting)

      expect(page).to have_content("Election created")
    end
  end

  describe "when elections with bb_status are present" do
    let!(:vote_election) { create :election, :bb_test, :vote, component: component }
    let!(:finished_election) { create :election, :bb_test, :results_published, component: component }
    let!(:key_ceremony_election) { create :election, :bb_test, :key_ceremony_ended, component: component }

    it "shows list of elections" do
      visit decidim_votings.voting_elections_log_path(voting)
      expect(page).to have_content("The election log will show you all relevant information about each voting. For example, the status of the key ceremony or tally or if results are published already. Click on the election you want the log information about.")
      expect(page).to have_selector(".card--list__item").exactly(4).times
      expect(page).to have_link(translated(vote_election.title))

      click_link translated(vote_election.title)

      expect(page).to have_content("Election Log")
      expect(page).to have_content("The voting process has started.")
    end
  end
end
