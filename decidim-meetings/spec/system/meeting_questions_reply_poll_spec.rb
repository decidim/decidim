# frozen_string_literal: true

require "spec_helper"

describe "Meeting poll answer" do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:user) do
    create(:user,
           :confirmed,
           organization:)
  end

  let(:meeting) { create(:meeting, :published, :online, :live, component:) }
  let(:meeting_path) do
    decidim_participatory_process_meetings.meeting_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      id: meeting.id
    )
  end
  let(:body_multiple_option_question) do
    {
      en: "This is the first question",
      ca: "Aquesta es la primera pregunta",
      es: "Esta es la primera pregunta"
    }
  end
  let(:body_single_option_question) do
    {
      en: "This is the second question",
      ca: "Aquesta es la segona pregunta",
      es: "Esta es la segunda pregunta"
    }
  end
  let!(:poll) { create(:poll, meeting:) }
  let!(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }

  context "when there are no questions" do
    it "does not show a link to reply poll" do
      login_as user, scope: :user
      visit meeting_path

      expect(page).to have_no_content("Reply poll")
    end
  end

  context "when all questions are unpublished" do
    let!(:question_multiple_option) { create(:meetings_poll_question, :unpublished, questionnaire:, body: body_multiple_option_question, question_type: "multiple_option") }
    let!(:question_single_option) { create(:meetings_poll_question, :unpublished, questionnaire:, body: body_single_option_question, question_type: "single_option") }

    before do
      login_as user, scope: :user
      visit meeting_path
      within("[aria-label='aside']") do
        click_link_or_button "Reply poll"
      end
    end

    it "does not list any question" do
      expect(page.all(".meeting-polls__question--admin").size).to eq(0)
      expect(page).to have_content("some questions will be sent")
    end
  end

  context "when questions are published" do
    let!(:question_multiple_option) { create(:meetings_poll_question, :published, questionnaire:, body: body_multiple_option_question, question_type: "multiple_option", max_choices: 2) }
    let!(:question_single_option) { create(:meetings_poll_question, :published, questionnaire:, body: body_single_option_question, question_type: "single_option") }

    before do
      login_as user, scope: :user
      visit meeting_path
      within("[aria-label='aside']") do
        click_link_or_button "Reply poll"
      end
    end

    it "allows to reply a question" do
      open_first_question
      expect(page).to have_css("details[data-question='#{question_multiple_option.id}'] input[type='checkbox']:not([disabled])")

      check question_multiple_option.answer_options.first.body["en"]
      click_on "Reply question"

      expect(page).to have_content("Question replied")
    end

    it "does not allow selecting two single options" do
      expect(page).to have_css("details[data-question='#{question_single_option.id}']:not([disabled])")
      find("details[data-question='#{question_single_option.id}']").click
      expect(page).to have_css("details[data-question='#{question_single_option.id}'] input[type='radio']:not([disabled])")

      choose question_single_option.answer_options.first.body["en"]
      choose question_single_option.answer_options.second.body["en"]
      answers = all("details[data-question='#{question_single_option.id}'] input[type='radio']")

      expect(answers[0]["checked"]).to be_falsy
      expect(answers[1]["checked"]).to be_truthy
      expect(answers[2]["checked"]).to be_falsy
    end

    it "does not allow selecting more than the maximum choices for multiple options" do
      open_first_question
      expect(page).to have_css("details[data-question='#{question_multiple_option.id}'] input[type='checkbox']:not([disabled])")

      check question_multiple_option.answer_options.first.body["en"]
      check question_multiple_option.answer_options.second.body["en"]
      check question_multiple_option.answer_options.third.body["en"]

      click_on "Reply question"
      expect(page).to have_content("You can choose a maximum of 2.")
    end
  end

  context "when questions are closed" do
    let!(:question_multiple_option) { create(:meetings_poll_question, :closed, questionnaire:, body: body_multiple_option_question, question_type: "multiple_option") }
    let!(:answer_user1) { create(:meetings_poll_answer, question: question_multiple_option, user:, questionnaire:) }
    let!(:answer_choice_user1) { create(:meetings_poll_answer_choice, answer: answer_user1) }

    before do
      login_as user, scope: :user
      visit meeting_path
      within("[aria-label='aside']") do
        click_link_or_button "View poll"
      end
    end

    it "shows the responses" do
      open_first_question

      expect(page).to have_content("0%")
      expect(page).to have_content("100%")
    end
  end

  private

  def questionnaire_edit_path
    Decidim::EngineRouter.admin_proxy(component).edit_meeting_poll_path(meeting_id: meeting.id)
  end

  def open_first_question
    expect(page).to have_css(".meeting-polls__question")
    find(".meeting-polls__question", match: :first).click
  end
end
