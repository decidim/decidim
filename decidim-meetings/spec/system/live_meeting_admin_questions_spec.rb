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
           organization: organization
  end

  let(:manifest_name) { "meetings" }

  let(:meeting) { create :meeting, :online, :live, component: component }
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
  let!(:poll) { create(:poll, meeting: meeting) }
  let!(:questionnaire) { create(:meetings_poll_questionnaire, questionnaire_for: poll) }
  let!(:question_multiple_option) { create(:meetings_poll_question, questionnaire: questionnaire, body: body_multiple_option_question, question_type: "multiple_option") }
  let!(:question_single_option) { create(:meetings_poll_question, questionnaire: questionnaire, body: body_single_option_question, question_type: "single_option") }

  before do
    visit meeting_live_event_path
    click_link "Administrate"
  end

  it "list the questions in the Administrate section" do
    expect(page.all(".meeting-polls__question--admin").size).to eq(2)
  end

  it "allows to edit a question in the administrator" do
    # Click first question and open it
    page.first(".meeting-polls__question--admin").click
    expect(page).to have_content("This is the first question")
    new_window = window_opened_by { click_link "Edit in the admin" }

    within_window new_window do
      expect(page).to have_current_path(questionnaire_edit_path)
    end
  end

  private

  def questionnaire_edit_path
    Decidim::EngineRouter.admin_proxy(component).edit_meeting_poll_path(meeting_id: meeting.id)
  end
end
