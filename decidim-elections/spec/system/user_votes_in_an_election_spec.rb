# frozen_string_literal: true

require "spec_helper"
require "decidim/elections/test/vote_examples"

describe "Dashboard" do
  let(:user) { create(:user, :confirmed, organization:) }
  let!(:election) { create(:election, :published, :ongoing, :with_internal_users_census, :with_questions, census_settings:) }
  let(:organization) { election.organization }
  let(:census_settings) do
    {
      "authorization_handlers" => authorization_handlers
    }
  end
  let(:authorization_handlers) do
    {}
  end
  let(:elections_path) { Decidim::EngineRouter.main_proxy(election.component).root_path }
  let(:election_path) { Decidim::EngineRouter.main_proxy(election.component).election_path(election) }
  let(:new_election_vote_path) { Decidim::EngineRouter.main_proxy(election.component).new_election_vote_path(election_id: election.id) }
  let(:waiting_election_votes_path) { Decidim::EngineRouter.main_proxy(election.component).waiting_election_votes_path(election_id: election.id) }
  let(:receipt_election_votes_path) { Decidim::EngineRouter.main_proxy(election.component).receipt_election_votes_path(election_id: election.id) }
  let(:confirm_election_votes_path) { Decidim::EngineRouter.main_proxy(election.component).confirm_election_votes_path(election_id: election.id) }
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
  end

  context "when user is logged in" do
    before do
      login_as user, scope: :user
      visit elections_path
      click_on translated_attribute(election.title)
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

  context "when the election has token csv census" do
    let(:election) { create(:election, :published, :ongoing, :with_token_csv_census, :with_questions) }
    let(:voter_uid) { election.voters.first.to_global_id.to_s }

    before do
      visit elections_path
      click_on translated_attribute(election.title)
    end

    it_behaves_like "a csv token votable election"
  end

  context "when is a per question election" do
    let(:election) { create(:election, :published, :ongoing, :with_internal_users_census, :per_question) }
    let!(:question1) { create(:election_question, :with_response_options, :voting_enabled, election:) }
    let!(:question2) { create(:election_question, :with_response_options, election:) }

    before do
      login_as user, scope: :user
      visit elections_path
      click_on translated_attribute(election.title)
    end

    it_behaves_like "a per question votable election"
  end
end
