# frozen_string_literal: true

shared_context "with elections router" do
  let(:router) { Decidim::EngineRouter.main_proxy(component).decidim_participatory_process_elections }
end

shared_examples "doesn't allow to vote" do
  include_context "with elections router"

  it "doesn't allow clicking in the vote button" do
    visit router.election_path(id: election.id)

    expect(page).not_to have_link("Vote")
  end

  it "doesn't allow to access directly to the vote page" do
    visit router.new_election_vote_path(election_id: election.id)

    expect(page).to have_content("You are not allowed to vote on this election at this moment.")
  end
end

shared_examples "allows to vote" do
  before do
    visit_component

    click_link translated(election.title)
    click_link "Vote"
  end

  it_behaves_like "uses the voting booth"

  it "don't show the preview alert" do
    expect(page).not_to have_content("This is a preview of the voting booth.")
  end
end

shared_examples "allows to preview booth" do
  include_context "with elections router"

  before do
    visit router.election_path(id: election.id)

    click_link "Preview"
  end

  it_behaves_like "uses the voting booth"

  it "shows the preview alert" do
    expect(page).to have_content("This is a preview of the voting booth.")
  end
end

shared_examples "uses the voting booth" do
  it "uses the voting booth" do
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
    within "#step-#{number - 1}" do
      question = election.questions[number - 1]
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
    new_answer = question.answers.select { |answer| non_selected.member?(answer) } .first
    old_answer = question.answers.select { |answer| selected.member?(answer) } .first

    selected.delete(old_answer)
    uncheck(translated(old_answer.title), allow_label_click: true)
    non_selected << old_answer

    non_selected.delete(new_answer)
    check(translated(new_answer.title), allow_label_click: true)
    selected << new_answer
  end

  def expect_only_one_step
    expect(page).to have_selector(".focus__step", count: 1)
  end

  def expect_not_valid
    expect(page).not_to have_link("Next")
  end

  def expect_valid
    expect(page).to have_link("Next")
  end
end
