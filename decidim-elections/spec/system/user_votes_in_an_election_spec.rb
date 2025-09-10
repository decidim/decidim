# frozen_string_literal: true

require "spec_helper"
require "decidim/elections/test/vote_examples"

describe "Dashboard" do
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:election) { create(:election, :published, :ongoing, :with_internal_users_census, census_settings:) }
  let!(:question1) { create(:election_question, :with_response_options, election:, question_type: "single_option") }
  let!(:question2) { create(:election_question, :with_response_options, election:, question_type: "multiple_option") }
  let(:organization) { election.organization }
  let(:census_settings) do
    {
      "authorization_handlers" => authorization_handlers
    }
  end
  let(:authorization_handlers) do
    {}
  end
  let(:election_path) { Decidim::EngineRouter.main_proxy(election.component).election_path(election) }
  let(:new_election_vote_path) { Decidim::EngineRouter.main_proxy(election.component).new_election_vote_path(election_id: election.id) }
  let(:waiting_election_votes_path) { Decidim::EngineRouter.main_proxy(election.component).waiting_election_votes_path(election_id: election.id) }
  let(:receipt_election_votes_path) { Decidim::EngineRouter.main_proxy(election.component).receipt_election_votes_path(election_id: election.id) }
  let(:confirm_election_votes_path) { Decidim::EngineRouter.main_proxy(election.component).confirm_election_votes_path(election_id: election.id) }
  let(:new_election_per_question_vote_path) { Decidim::EngineRouter.main_proxy(election.component).new_election_per_question_vote_path(election_id: election.id) }
  let(:voter_uid) { user.to_global_id.to_s }

  def election_vote_path(question)
    Decidim::EngineRouter.main_proxy(election.component).election_vote_path(election_id: election.id, id: question.id)
  end

  before do
    switch_to_host(organization.host)
  end

  context "when user is not logged in" do
    before do
      visit election_path
    end

    it_behaves_like "an internal users authentication voter form"

    context "and csv token census is enabled" do
      let(:election) { create(:election, :published, :ongoing, :with_token_csv_census) }
      let(:voter_uid) { election.voters.first.to_global_id.to_s }

      it_behaves_like "a csv token votable election"

      context "when user has already voted" do
        let!(:vote1) { create(:election_vote, voter_uid:, question: election.questions.first, response_option: election.questions.first.response_options.first) }
        let!(:vote2) { create(:election_vote, voter_uid:, question: election.questions.second, response_option: election.questions.second.response_options.first) }

        it_behaves_like "a csv token editable votable election"
      end
    end
  end

  context "when user is logged in" do
    before do
      login_as user, scope: :user
      visit election_path
    end

    it_behaves_like "a votable election"

    context "when a verification methods is enabled" do
      let(:authorization_handlers) do
        {
          "dummy_authorization_handler" => {
            "options" => {
              "allowed_postal_codes" => "08002"
            }
          }
        }
      end

      it_behaves_like "an internal users verification voter form"
    end
  end

  context "when the user has voted" do
    let(:election) { create(:election, :published, :ongoing, :with_internal_users_census) }
    let!(:vote1) { create(:election_vote, voter_uid:, question: election.questions.first, response_option: election.questions.first.response_options.first) }
    let!(:vote2) { create(:election_vote, voter_uid:, question: election.questions.second, response_option: election.questions.second.response_options.first) }

    before do
      login_as user, scope: :user
      visit election_path
    end

    it_behaves_like "an editable votable election"

    context "when the election has finished" do
      let(:election) { create(:election, :published, :finished, :with_internal_users_census) }

      it "does not allow to vote" do
        expect(page).to have_no_link("Vote")
        expect(page).to have_no_content("You have already voted.")
        visit new_election_vote_path
        expect(page).to have_content("You are not authorized to perform this action.")
        expect(page).to have_current_path("/")
      end
    end
  end

  context "when the election is per_question" do
    let(:election) { create(:election, :published, :ongoing, :with_internal_users_census, :per_question) }

    it "redirects to the per question vote path" do
      visit new_election_vote_path
      expect(page).to have_current_path(new_election_per_question_vote_path)
    end
  end
end
