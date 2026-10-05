# frozen_string_literal: true

require "spec_helper"

describe "Admin manages survey display conditions" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:surveys_component, participatory_space: participatory_process) }
  let(:survey) { create(:survey, component:, questionnaire: build(:questionnaire)) }
  let(:questionnaire) { survey.questionnaire }
  let!(:condition_question) { create(:questionnaire_question, :with_response_options, questionnaire:, question_type: "single_option") }
  let!(:question) { create(:questionnaire_question, questionnaire:, question_type: "single_option", position: 1) }
  let!(:display_condition) do
    create(:display_condition, :responded, question:, condition_question:)
  end
  let(:user) { create(:user, :admin, :confirmed, :admin_terms_accepted, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "renders the response options url for the display condition fields" do
    visit Decidim::EngineRouter.admin_proxy(component).edit_questions_questions_survey_path(survey)

    expect(page).to have_css(".questionnaire-question", count: 2)

    urls = page.html.scan(/data-url="([^"]+)"/).flatten.uniq
    expect(urls).to include(
      include("manage/response_options.json?id=#{condition_question.id}")
    )
  end

  it "responds with the response options of the question in the ajax endpoint" do
    option_body = condition_question.response_options.first.body["en"]

    visit Decidim::EngineRouter.admin_proxy(component).response_options_survey_path(
      id: condition_question.id,
      survey_id: survey.id,
      format: :json
    )

    expect(page).to have_text(option_body)
  end
end
