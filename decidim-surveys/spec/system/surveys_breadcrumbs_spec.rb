# frozen_string_literal: true

require "spec_helper"

describe "Surveys Breadcrumb" do
  include_context "with a component"

  let(:manifest_name) { "surveys" }
  let(:title) do
    {
      "en" => "Survey's title",
      "ca" => "Títol de l'enquesta'",
      "es" => "Título de la encuesta"
    }
  end
  let!(:questionnaire) { create(:questionnaire, title:) }
  let!(:survey) { create(:survey, :published, component:, questionnaire:) }

  context "when the survey does not allow responses" do
    it "shows the correct information in breadcrumb (space, component)" do
      visit_component

      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
      end
    end
  end

  context "when the survey has questions' responses published" do
    let(:question_single_option) { create(:questionnaire_question, :with_response_options, position: 0, question_type: "single_option", questionnaire:) }

    before do
      10.times do
        response = create(:response, question: question_single_option, questionnaire:)
        response_option = question_single_option.response_options.sample
        create(:response_choice, response_option:, response:, matrix_row: nil)
      end
    end

    it "shows the correct information in breadcrumb (space, component, questionnaire)" do
      visit_component
      choose "All"
      click_on translated_attribute(questionnaire.title)

      within(".menu-bar") do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(questionnaire.title))
      end
    end
  end
end
