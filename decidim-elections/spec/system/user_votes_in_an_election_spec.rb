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
    organization.update!(available_authorizations: %w(dummy_authorization_handler))
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
        expect(page).to have_no_text("You have already voted.")
        visit new_election_vote_path
        expect(page).to have_text("You are not authorized to perform this action.")
        expect(page).to have_current_path(decidim.root_path)
      end
    end
  end

  context "when question has max_choices limit", :js do
    let(:election_with_limit) { create(:election, :published, :ongoing, :with_internal_users_census, component: election.component) }
    let!(:question_with_limit) { create(:election_question, election: election_with_limit, question_type: "multiple_option", max_choices: 2, body: { en: "Choose your options" }) }
    let!(:option1) { create(:election_response_option, question: question_with_limit, body: { en: "Option 1" }) }
    let!(:option2) { create(:election_response_option, question: question_with_limit, body: { en: "Option 2" }) }
    let!(:option3) { create(:election_response_option, question: question_with_limit, body: { en: "Option 3" }) }
    let(:new_election_with_limit_vote_path) { Decidim::EngineRouter.main_proxy(election.component).new_election_vote_path(election_id: election_with_limit.id) }

    before do
      login_as user, scope: :user
      visit new_election_with_limit_vote_path
    end

    it "shows max_choices in question title" do
      expect(page).to have_text("Choose your options (Max choices: 2)")
    end

    it "shows alert when selecting more than max_choices" do
      check "Option 1"
      check "Option 2"
      check "Option 3"

      expect(page).to have_css(".max-choices-alert", visible: :visible)
    end

    it "hides alert when deselecting options" do
      check "Option 1"
      check "Option 2"
      check "Option 3"

      expect(page).to have_css(".max-choices-alert", visible: :visible)

      uncheck "Option 3"

      expect(page).to have_css(".max-choices-alert", visible: :hidden)
    end

    it "shows server-side validation error when exceeding limit" do
      check "Option 1"
      check "Option 2"
      check "Option 3"

      click_on "Next"

      expect(page).to have_text("You cannot select more than 2 options")
    end

    context "when question is single_option" do
      let!(:single_question) { create(:election_question, election: election_with_limit, question_type: "single_option", body: { en: "Choose one option" }) }

      it "does not show max_choices for single_option questions" do
        expect(page).to have_no_text("Choose one option (Max choices:")
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
