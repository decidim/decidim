# frozen_string_literal: true

require "spec_helper"

describe "Admin manages elections questions" do
  let(:current_organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization: current_organization) }
  let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "elections") }
  let(:manifest_name) { "elections" }
  let!(:election) { create(:election, component: current_component) }
  let(:question) { create(:election_question, election:) }
  let(:body) do
    {
      en: "This is the first question",
      ca: "Aquesta es la primera pregunta",
      es: "Esta es la primera pregunta"
    }
  end
  let(:description) do
    {
      en: "This is the first question description",
      ca: "Aquesta es la primera pregunta descripcio",
      es: "Esta es la primera pregunta descripcion"
    }
  end

  include_context "when managing a component as an admin"

  before do
    visit questions_edit_path
  end

  it "opens a questions tab" do
    expect(page).to have_content("Question must have at least two answers in order go to the next step.")
  end

  context "when an admin user add a question" do
    it "adds a question with response options" do
      question_body = ["This is the first question", "This is the second question"]
      question_description = ["This is the first question description"]
      response_options_body = [
        ["This is the Q1 first option", "This is the Q1 second option", "This is the Q1 third option"],
        ["This is the Q2 first option", "This is the Q2 second option", "This is the Q2 third option"]
      ]

      within "form.edit_questions" do
        click_on "Add question"
        click_on "Add question"
        expand_all_questions

        page.all(".questionnaire-question").each_with_index do |question, idx|
          within question do
            fill_in find_nested_form_field_locator("body_en"), with: question_body[idx]
          end

          fill_in_editor find_nested_form_field_locator("description_en"), with: question_description[0]
        end

        page.all(".questionnaire-question").each do |question|
          within question do
            select "Single option", from: "Type"
            click_on "Add response option"
          end
        end

        page.all(".questionnaire-question").each_with_index do |question, question_idx|
          question.all(".questionnaire-question-response-option").each_with_index do |question_response_option, response_option_idx|
            within question_response_option do
              fill_in find_nested_form_field_locator("body_en"), with: response_options_body[question_idx][response_option_idx]
            end
          end
        end
      end

      click_on "Save and continue"

      expect(page).to have_admin_callout("successfully")

      visit_questions_edit_path_and_expand_all

      expect(page).to have_css("input[value='This is the first question']")
      expect(page).to have_content("This is the first question description")
      expect(page).to have_css("input[value='This is the Q1 first option']")
      expect(page).to have_css("input[value='This is the Q1 second option']")
      expect(page).to have_css("input[value='This is the Q1 third option']")
      expect(page).to have_css("input[value='This is the second question']")
      expect(page).to have_css("input[value='This is the Q2 first option']")
      expect(page).to have_css("input[value='This is the Q2 second option']")
      expect(page).to have_css("input[value='This is the Q2 third option']")
    end
  end

  private

  def find_nested_form_field_locator(attribute, visible: :visible)
    find_nested_form_field(attribute, visible:)["id"]
  end

  def find_nested_form_field(attribute, visible: :visible)
    current_scope.find(nested_form_field_selector(attribute), visible:, match: :first)
  end

  def nested_form_field_selector(attribute)
    "[id$=#{attribute}]"
  end

  def expand_all_questions
    click_on "Expand all questions"
  end

  def visit_questions_edit_path_and_expand_all
    visit questions_edit_path
    expand_all_questions
  end

  def questions_edit_path
    Decidim::EngineRouter.admin_proxy(current_component).edit_questions_election_path(election)
  end
end
