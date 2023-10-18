# frozen_string_literal: true

shared_examples "does not allow to vote" do
  it "does not allow clicking in the vote button" do
    visit router.election_path(id: election.id)

    expect(page).not_to have_link("Vote")
  end

  it "does not allow to access directly to the vote page" do
    visit router.new_election_vote_path(election_id: election.id)

    expect(page).to have_content("You are not allowed to vote on this election at this moment.")
  end
end

shared_examples "allows admins to preview the voting booth" do
  let(:user) { create(:user, :admin, :confirmed, organization: component.organization) }

  before do
    visit router.election_path(id: election.id)

    click_link "Preview"
  end

  it { uses_the_voting_booth }

  it "shows the preview alert" do
    expect(page).to have_content("This is a preview of the voting booth.")
  end
end

shared_examples "does not allow admins to preview the voting booth" do
  let(:user) { create(:user, :admin, :confirmed, organization: component.organization) }

  it "does not allow clicking the preview button" do
    visit router.election_path(id: election.id)

    expect(page).not_to have_link("Preview")
  end

  it "does not allow to access directly to the vote page" do
    visit router.new_election_vote_path(election_id: election.id)

    expect(page).to have_content("You are not allowed to vote on this election at this moment.")
  end
end

def uses_the_voting_booth
  selected_answers = []
  non_selected_answers = []

  # shows a yes/no/abstention question: radio buttons, no random order, no extra information
  question_step(1) do |question|
    expect_not_valid

    select_answers(question, 1, selected_answers, non_selected_answers)
  end

  # shows a projects question: checkboxes, 6 maximum selections, random order with extra information
  question_step(2) do |question|
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

  # shows a nota question: checkboxes, random order without extra information, nota checked
  question_step(4) do |_question|
    check(I18n.t("decidim.elections.votes.new.nota_option"), allow_label_click: true)

    expect(page).to have_selector("label[aria-disabled='true']").exactly(8).times

    expect_valid
  end

  # confirm step
  non_question_step("#step-confirm") do
    expect(page).to have_content("Confirm your vote")

    selected_answers.each { |answer| expect(page).to have_i18n_content(answer.title) }
    non_selected_answers.each { |answer| expect(page).not_to have_i18n_content(answer.title) }

    within "#edit-step-2" do
      click_button("edit")
    end
  end

  # edit step 2
  question_step(2) do |question|
    change_answer(question, selected_answers, non_selected_answers)
  end

  question_step(3)

  question_step(4)

  # confirm step
  non_question_step("#step-confirm") do
    expect(page).to have_content("Confirm your vote")

    selected_answers.each { |answer| expect(page).to have_i18n_content(answer.title) }
    non_selected_answers.each { |answer| expect(page).not_to have_i18n_content(answer.title) }

    click_button("Confirm")
  end

  # cast ballot
  non_question_step("#step-ballot_decision") do
    click_button("Cast ballot")
  end

  # confirmed vote page
  expect(page).to have_content("Vote confirmed")
  expect(page).to have_content("Your vote has been cast!")
end

def question_step(number)
  expect_only_one_step
  within "#step-#{number - 1}" do
    question = election.questions[number - 1]

    expect(page).to have_content("Question #{number} of 4")
    expect(page).to have_i18n_content(question.title)

    yield question if block_given?

    click_button("Next")
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
  new_answer = question.answers.select { |answer| non_selected.member?(answer) }.first
  old_answer = question.answers.select { |answer| selected.member?(answer) }.first

  selected.delete(old_answer)
  uncheck(translated(old_answer.title), allow_label_click: true)
  non_selected << old_answer

  non_selected.delete(new_answer)
  check(translated(new_answer.title), allow_label_click: true)
  selected << new_answer
end

def expect_only_one_step
  expect(page).to have_selector('[id^="step"]:not([hidden])', count: 1)
end

def expect_not_valid
  expect(page).not_to have_button("Next")
end

def expect_valid
  expect(page).to have_button("Next")
end
