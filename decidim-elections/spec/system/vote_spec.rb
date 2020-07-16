# frozen_string_literal: true

require "spec_helper"

describe "Vote in an election", type: :system do
  let(:manifest_name) { "elections" }
  let(:election) { create :election, :complete, :published, component: component }
  let(:user) { create(:user, :confirmed, organization: component.organization) }

  before do
    election.reload
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  include_context "with a component"

  shared_examples "doesn't allow to vote" do
    it "doesn't allow clicking in the vote button" do
      visit_component

      click_link translated(election.title)

      expect(page).to_not have_link("Vote")
    end

    it "doesn't allow to access directly to page" do
      visit Decidim::EngineRouter.main_proxy(component).decidim_participatory_process_elections.new_election_vote_path(election_id: election.id)

      expect(page).to have_content("You are not allowed to vote on this election at this moment.")
    end
  end

  context "when the election did not started yet" do
    let(:election) { create :election, :upcoming, :published, component: component }

    it_behaves_like "doesn't allow to vote"
  end

  context "when the election has finished" do
    let(:election) { create :election, :finished, :published, component: component }

    it_behaves_like "doesn't allow to vote"
  end

  context "when the election requires permissions to vote" do
    before do
      permissions = {
        vote: {
          authorization_handlers: {
            "dummy_authorization_handler" => { "options" => {} }
          }
        }
      }

      component.update!(permissions: permissions)
    end

    it "shows a modal dialog" do
      visit_component

      click_link translated(election.title)
      click_link "Vote"

      expect(page).to have_content("Authorization required")
    end
  end

  it "allows to vote" do
    visit_component

    click_link translated(election.title)
    click_link "Vote"

    selected_answers = []
    non_selected_answers = []

    # shows a yes/no/abstention question: radio buttons, no random order, no extra information
    question_step(1) do |question|
      expect_not_valid

      select_answers(question, 1, selected_answers, non_selected_answers)
    end

    # shows a projects question: checkboxes, 6 maximum selections, random order with extra information
    question_step(2) do |question|
      expect_valid

      select_answers(question, 3, selected_answers, non_selected_answers)

      expect_valid

      check(translated(non_selected_answers.last.title), allow_label_click: true)

      expect_not_valid

      uncheck(translated(non_selected_answers.last.title), allow_label_click: true)
    end

    # shows a candidates question: checkboxes, random order without extra information
    question_step(3) do |question|
      select_answers(question, 5, selected_answers, non_selected_answers)
    end

    # confirm step
    non_question_step("#step-3") do
      expect(page).to have_content("CONFIRM YOUR VOTE")

      selected_answers.each { |answer| expect(page).to have_i18n_content(answer.title) }
      non_selected_answers.each { |answer| expect(page).not_to have_i18n_content(answer.title) }

      within "#edit-step-2" do
        click_link("edit")
      end
    end

    # edit step 2
    question_step(2) do |question|
      change_answer(question, selected_answers, non_selected_answers)
    end

    question_step(3)

    # confirm step
    non_question_step("#step-3") do
      expect(page).to have_content("CONFIRM YOUR VOTE")

      selected_answers.each { |answer| expect(page).to have_i18n_content(answer.title) }
      non_selected_answers.each { |answer| expect(page).not_to have_i18n_content(answer.title) }

      click_link("Confirm")
    end

    # ciphering animation step
    non_question_step("#encrypting") do
      expect(page).to have_content("Encoding vote...")
      expect(page).to have_content("Your vote is being encrypted to ensure you can cast it anonymously.")
    end

    sleep(3)

    # confirmed vote page
    non_question_step("#confirmed_page") do
      expect(page).to have_content("Vote confirmed")
      expect(page).to have_content("Your vote has already been cast!")
    end
  end

  def question_step(number)
    expect_only_one_step
    within "#step-#{number-1}" do
      question = election.questions[number-1]
      expect(page).to have_content("QUESTION #{number} OF 3")
      expect(page).to have_i18n_content(question.title)

      yield question if block_given?

      click_link("Next")
    end
  end

  def non_question_step(id)
    expect_only_one_step
    within id do
      yield
    end
  end

  def select_answers(question, number, selected, non_selected)
    answers = question.answers.to_a
    number.times do
      answer = answers.delete(answers.sample)
      selected << answer
      if number == 1
        choose(translated(answer.title), allow_label_click: true)
      else
        check(translated(answer.title), allow_label_click: true)
      end
    end
    non_selected.concat answers
  end

  def change_answer(question, selected, non_selected)
    new_answer = question.answers.select {|answer| non_selected.member?(answer) } .first
    old_answer = question.answers.select {|answer| selected.member?(answer) } .first

    selected.delete(old_answer)
    uncheck(translated(old_answer.title), allow_label_click: true)
    non_selected << old_answer

    non_selected.delete(new_answer)
    check(translated(new_answer.title), allow_label_click: true)
    selected << new_answer
  end

  def expect_only_one_step
    expect(page).to have_selector('.focus__step', count: 1)
  end

  def expect_not_valid
    expect(page).to_not have_link("Next")
  end

  def expect_valid
    expect(page).to have_link("Next")
  end
end
