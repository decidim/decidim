# frozen_string_literal: true

require "spec_helper"

describe "Meeting poll administration" do
  include_context "when managing a component" do
    let(:component_organization_traits) { admin_component_organization_traits }
  end

  let(:admin_component_organization_traits) { [] }

  let(:user) do
    create(:user,
           :admin,
           :confirmed,
           organization:)
  end
  let(:user2) do
    create(:user,
           :admin,
           :confirmed,
           organization:)
  end

  let(:manifest_name) { "meetings" }

  let(:meeting) { create(:meeting, :published, component:) }
  let(:meeting_path) do
    decidim_participatory_process_meetings.meeting_path(
      participatory_process_slug: participatory_process.slug,
      component_id: component.id,
      id: meeting.id,
      locale: I18n.locale
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
    stub_geocoding_coordinates([meeting.latitude, meeting.longitude])
  end

  context "when all questions are unpublished" do
    let!(:question_multiple_option) { create(:meetings_poll_question, :unpublished, questionnaire:, body: body_multiple_option_question, question_type: "multiple_option") }
    let!(:question_single_option) { create(:meetings_poll_question, :unpublished, questionnaire:, body: body_single_option_question, question_type: "single_option") }

    before do
      visit meeting_path
      within("[aria-label='aside']") do
        click_link_or_button "Reply poll"
      end
      click_link_or_button "Administrate"
    end

    it "list the questions in the Administrate section" do
      expect(page.all(".meeting-polls__question--admin:not([disabled])", visible: :visible).size).to eq(2)
    end

    it "shows the status of each question" do
      expect(page).to have_content("Pending to be sent", count: 2)
    end

    it "allows to edit a question in the administrator" do
      open_first_question

      expect(page).to have_content("This is the first question")
      new_window = window_opened_by { click_on "Edit in the admin" }

      within_window new_window do
        expect(page).to have_current_path(questionnaire_edit_path)
      end
    end

    it "allows to publish an unpublished question" do
      open_first_question
      expect(page).to have_css(".meeting-polls__admin-action-question:not([disabled])", visible: :visible)

      within ".meeting-polls__admin-action-question" do
        click_on "Send"
        expect(page).to have_content("Sent")
        expect(page).to have_content("0 received responses")
      end
      expect(page).to have_css("[data-question='#{question_multiple_option.id}']", text: "Sent (open)")
    end
  end

  context "when there is a published question with responses" do
    let!(:question_multiple_option) { create(:meetings_poll_question, :published, questionnaire:, body: body_multiple_option_question, question_type: "multiple_option") }

    let!(:response_user1) { create(:meetings_poll_response, question: question_multiple_option, user:, questionnaire:) }
    let!(:response_user2) { create(:meetings_poll_response, question: question_multiple_option, user: user2, questionnaire:) }

    let!(:response_choice_user1) { create(:meetings_poll_response_choice, response: response_user1, response_option: question_multiple_option.response_options.first) }
    let!(:response_choice_user2) { create(:meetings_poll_response_choice, response: response_user2, response_option: question_multiple_option.response_options.first) }

    before do
      visit meeting_path
      within("[aria-label='aside']") do
        click_link_or_button "Reply poll"
      end

      click_link_or_button "Administrate"
    end

    it "allows to see question responses" do
      open_first_question

      expect(page).to have_content("0%")
      expect(page).to have_content("100%")
    end

    it "shows the status of each question" do
      expect(page).to have_content("Sent (open)", count: 1)
    end

    it "allows to close a published question" do
      open_first_question
      expect(page).to have_css(".meeting-polls__admin-action-results:not([disabled])", visible: :visible)

      within ".meeting-polls__admin-action-results" do
        click_on "Send"
        expect(page).to have_content("Sent")
      end

      question_multiple_option.reload
      expect(question_multiple_option).to be_closed
      expect(page).to have_css("[data-question='#{question_multiple_option.id}']", text: "Results sent (closed)")
    end
  end

  private

  def questionnaire_edit_path
    Decidim::EngineRouter.admin_proxy(component).edit_meeting_poll_path(meeting_id: meeting.id)
  end

  def open_first_question
    expect(page).to have_css(".meeting-polls__question--admin:not([disabled])", visible: :visible)
    sleep(2)
    find(".meeting-polls__question--admin", match: :first).click
  end
end
