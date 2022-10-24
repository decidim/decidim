# frozen_string_literal: true

require "spec_helper"

describe "Meeting live event poll administration", type: :system do
  include_context "when managing a component" do
    let(:component_organization_traits) { admin_component_organization_traits }
  end

  let(:admin_component_organization_traits) { [] }

  let(:user) do
    create :user,
           :admin,
           :confirmed,
           organization:
  end
  let(:user2) do
    create :user,
           :admin,
           :confirmed,
           organization:
  end

  let(:manifest_name) { "meetings" }

  let(:meeting) { create :meeting, :published, :online, :live, component: }
  let(:meeting_path) do
    decidim_participatory_process_meetings.meeting_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      id: meeting.id
    )
  end
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
    visit meeting_live_event_path
    click_button "Administrate"
  end

  context "when all questions are unpublished" do
    let!(:question_multiple_option) { create(:meetings_poll_question, :unpublished, questionnaire:, body: body_multiple_option_question, question_type: "multiple_option") }
    let!(:question_single_option) { create(:meetings_poll_question, :unpublished, questionnaire:, body: body_single_option_question, question_type: "single_option") }

    it "list the questions in the Administrate section" do
      expect(page.all(".meeting-polls__question--admin").size).to eq(2)
    end

    it "allows to edit a question in the administrator" do
      open_first_question

      expect(page).to have_content("This is the first question")
      new_window = window_opened_by { click_link "Edit in the admin" }

      within_window new_window do
        expect(page).to have_current_path(questionnaire_edit_path)
      end
    end

    it "allows to publish an unpublished question" do
      open_first_question

      within ".meeting-polls__admin-action-question" do
        click_button "Send"
        expect(page).to have_content("Sent")
        expect(page).to have_content("0 received answers")
      end
    end
  end

  context "when there's a published question with answers" do
    let!(:question_multiple_option) { create(:meetings_poll_question, :published, questionnaire:, body: body_multiple_option_question, question_type: "multiple_option") }

    let!(:answer_user1) { create(:meetings_poll_answer, question: question_multiple_option, user:, questionnaire:) }
    let!(:answer_user2) { create(:meetings_poll_answer, question: question_multiple_option, user: user2, questionnaire:) }

    let!(:answer_choice_user1) { create(:meetings_poll_answer_choice, answer: answer_user1, answer_option: question_multiple_option.answer_options.first) }
    let!(:answer_choice_user2) { create(:meetings_poll_answer_choice, answer: answer_user2, answer_option: question_multiple_option.answer_options.first) }

    it "allows to see question answers" do
      open_first_question

      expect(page).to have_content("0%")
      expect(page).to have_content("100%")
    end

    it "allows to close a published question" do
      open_first_question

      within ".meeting-polls__admin-action-results" do
        click_button "Send"
        expect(page).to have_content("Sent")
      end

      question_multiple_option.reload
      expect(question_multiple_option).to be_closed
    end
  end

  private

  def questionnaire_edit_path
    Decidim::EngineRouter.admin_proxy(component).edit_meeting_poll_path(meeting_id: meeting.id)
  end

  def open_first_question
    page.first(".meeting-polls__question--admin").click
  end
end
