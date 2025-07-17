# frozen_string_literal: true

require "spec_helper"
require "decidim/elections/test/vote_examples"

describe "Dashboard" do
  let(:election) { create(:election, :published, :ongoing, :real_time, :with_internal_users_census, :with_questions) }
  let(:question1) { election.questions.first }
  let(:question2) { election.questions.second }
  let(:option11) { question1.response_options.first }
  let(:option12) { question1.response_options.second }
  let(:option21) { question2.response_options.first }
  let(:option22) { question2.response_options.second }
  let(:organization) { election.organization }
  let(:elections_path) { Decidim::EngineRouter.main_proxy(election.component).root_path }

  before do
    switch_to_host(organization.host)
    visit elections_path
    click_on translated_attribute(election.title)
  end

  it_behaves_like "shows questions in an election"

  def expect_vote_percent(question, option, percent)
    div = find("[data-option-votes-percent-text='#{question.id},#{option.id}']")
    expect(div).to have_content(percent)
  end

  def expect_vote_count(question, option, count)
    div = find("[data-option-votes-count-text='#{question.id},#{option.id}']")
    expect(div).to have_content("#{count} vote")
  end

  it "shows the results" do
    expect(page).to have_content("Vote statistics")
    within "#question-#{question1.id}" do
      expect(page).to have_content(translated_attribute(question1.body))
      expect(page).to have_content(translated_attribute(option11.body))
      expect(page).to have_content(translated_attribute(option12.body))
    end
    within "#question-#{question2.id}" do
      expect(page).to have_content(translated_attribute(question2.body))
      expect(page).to have_content(translated_attribute(option21.body))
      expect(page).to have_content(translated_attribute(option22.body))
    end

    expect_vote_percent(question1, option11, "0.0%")
    expect_vote_count(question1, option11, "0")
    expect_vote_percent(question1, option12, "0.0%")
    expect_vote_count(question1, option12, "0")
    expect_vote_percent(question2, option21, "0.0%")
    expect_vote_count(question2, option21, "0")
    expect_vote_percent(question2, option22, "0.0%")
    expect_vote_count(question2, option22, "0")

    create(:election_vote, question: question1, voter_uid: "voter1", response_option: option11)
    create(:election_vote, question: question2, voter_uid: "voter1", response_option: option22)
    # wait for javascript to refresh the results
    sleep 5
    expect_vote_percent(question1, option11, "100.0%")
    expect_vote_count(question1, option11, "1")
    expect_vote_percent(question1, option12, "0.0%")
    expect_vote_count(question1, option12, "0")
    expect_vote_percent(question2, option21, "0.0%")
    expect_vote_count(question2, option21, "0")
    expect_vote_percent(question2, option22, "100.0%")
    expect_vote_count(question2, option22, "1")
  end

  context "when the election is per question" do
    let(:election) { create(:election, :published, :ongoing, :per_question, :with_internal_users_census) }
    let!(:question1) { create(:election_question, :with_response_options, :voting_enabled, election:) }
    let!(:question2) { create(:election_question, :with_response_options, election:) }
    let(:option11) { question1.response_options.first }
    let(:option12) { question1.response_options.second }
    let(:option21) { question2.response_options.first }
    let(:option22) { question2.response_options.second }

    before do
      question1.update(published_results_at: Time.current)
      visit elections_path
      click_on translated_attribute(election.title)
    end

    context "when all questions are enabled" do
      let!(:question2) { create(:election_question, :with_response_options, :voting_enabled, election:) }

      it_behaves_like "shows questions in an election"
    end

    it "shows the results for each question" do
      within "#question-#{question1.id}" do
        expect(page).to have_content(translated_attribute(question1.body))
        expect(page).to have_content(translated_attribute(option11.body))
        expect(page).to have_content(translated_attribute(option12.body))
      end
      expect(page).to have_no_selector("#question-#{question2.id}")
      expect_vote_percent(question1, option11, "0.0%")
      expect_vote_count(question1, option11, "0")
      expect_vote_percent(question1, option12, "0.0%")
      expect_vote_count(question1, option12, "0")

      question1.update(published_results_at: Time.current)
      question2.update(voting_enabled_at: Time.current)
      create(:election_vote, question: question1, voter_uid: "voter1", response_option: option11)
      create(:election_vote, question: question2, voter_uid: "voter1", response_option: option21)

      # wait for javascript to refresh the results
      sleep 5
      expect_vote_percent(question1, option11, "100.0%")
      expect_vote_count(question1, option11, "1")
      expect_vote_percent(question1, option12, "0.0%")
      expect_vote_count(question1, option12, "0")
      within "#question-#{question2.id}" do
        expect(page).to have_content(translated_attribute(question2.body))
        expect(page).to have_content(translated_attribute(option21.body))
        expect(page).to have_content(translated_attribute(option22.body))
      end
      expect_vote_percent(question2, option21, "0.0%")
      expect_vote_count(question2, option21, "0")
      expect_vote_percent(question2, option22, "0.0%")
      expect_vote_count(question2, option22, "0")
    end
  end
end
