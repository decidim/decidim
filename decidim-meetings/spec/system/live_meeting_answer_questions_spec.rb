# frozen_string_literal: true

require "spec_helper"

describe "Meeting live event poll answer", type: :system do
  include_context "with a component"
  let(:manifest_name) { "meetings" }

  let(:user) do
    create :user,
           :confirmed,
           organization:
  end
  let(:user2) do
    create :user,
           :confirmed,
           organization:
  end

  let(:meeting) { create :meeting, :published, :online, :live, component: }
  let(:meeting_live_event_path) do
    decidim_participatory_process_meetings.meeting_live_event_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      meeting_id: meeting.id
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

  before do
    login_as user, scope: :user
    visit meeting_live_event_path
  end

  context "when all questions are unpublished" do
    let!(:question_multiple_option) { create(:meetings_poll_question, :unpublished, questionnaire:, body: body_multiple_option_question, question_type: "multiple_option") }
    let!(:question_single_option) { create(:meetings_poll_question, :unpublished, questionnaire:, body: body_single_option_question, question_type: "single_option") }

    before do
      visit meeting_live_event_path
    end

    it "doesn't list any question" do
      click_button "Questions (0)"
      expect(page.all(".meeting-polls__question--admin").size).to eq(0)
    end
  end

  context "when questions are published" do
    let!(:question_multiple_option) { create(:meetings_poll_question, :published, questionnaire:, body: body_multiple_option_question, question_type: "multiple_option") }
    let!(:question_single_option) { create(:meetings_poll_question, :published, questionnaire:, body: body_single_option_question, question_type: "single_option") }

    before do
      visit meeting_live_event_path
    end

    it "allows to reply a question" do
      click_button "Questions (2)"
      open_first_question

      check question_multiple_option.answer_options.first.body["en"]
      click_button "Reply question"

      expect(page).to have_content("Question replied")
    end
  end

  context "when questions are closed" do
    let!(:question_multiple_option) { create(:meetings_poll_question, :closed, questionnaire:, body: body_multiple_option_question, question_type: "multiple_option") }
    let!(:answer_user1) { create(:meetings_poll_answer, question: question_multiple_option, user:, questionnaire:) }
    let!(:answer_choice_user1) { create(:meetings_poll_answer_choice, answer: answer_user1) }

    before do
      visit meeting_live_event_path
    end

    it "shows the responses" do
      click_button "Questions (1)"
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
    page.first(".meeting-polls__question").click
  end
end
