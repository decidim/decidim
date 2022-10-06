# frozen_string_literal: true

require "spec_helper"

require "decidim/forms/test/shared_examples/manage_questionnaires/add_questions"
require "decidim/forms/test/shared_examples/manage_questionnaires/update_questions"
require "decidim/forms/test/shared_examples/manage_questionnaires/add_display_conditions"
require "decidim/forms/test/shared_examples/manage_questionnaires/update_display_conditions"

shared_examples_for "manage questionnaires" do
  let(:body) do
    {
      en: "This is the first question",
      ca: "Aquesta es la primera pregunta",
      es: "Esta es la primera pregunta"
    }
  end

  let(:title_and_description_body) do
    {
      en: "Este es el primer separador de texto",
      ca: "Aquest és el primer separador de text",
      es: "Esta es la primera pregunta"
    }
  end

  it "updates the questionnaire" do
    visit questionnaire_edit_path

    new_description = {
      en: "<p>New description</p>",
      ca: "<p>Nova descripció</p>",
      es: "<p>Nueva descripción</p>"
    }

    within "form.edit_questionnaire" do
      fill_in_i18n_editor(:questionnaire_description, "#questionnaire-description-tabs", new_description)
      click_button "Save"
    end

    expect(page).to have_admin_callout("successfully")

    visit questionnaire_public_path

    expect(page).to have_content("New description")
  end

  context "when the questionnaire is not already answered" do
    before do
      visit questionnaire_edit_path
    end

    it_behaves_like "add questions"
    it_behaves_like "update questions"
    it_behaves_like "add display conditions"
    it_behaves_like "update display conditions"
  end

  context "when the questionnaire is already answered" do
    let!(:question) { create(:questionnaire_question, questionnaire:, body:, question_type: "multiple_option") }
    let!(:answer) { create(:answer, questionnaire:, question:) }

    it "cannot modify questionnaire questions" do
      visit questionnaire_edit_path

      expect(page).to have_no_content("Add question")
      expect(page).to have_no_content("Remove")

      expand_all_questions

      expect(page).to have_selector("input[value='This is the first question'][disabled]")
      expect(page).to have_selector("select[id$=question_type][disabled]")
      expect(page).to have_selector("select[id$=max_choices][disabled]")
      expect(page).to have_selector("input[id$=max_characters][disabled]")
      expect(page).to have_selector(".ql-editor[contenteditable=false]")
    end
  end

  private

  def find_nested_form_field_locator(attribute, visible: :visible)
    find_nested_form_field(attribute, visible:)["id"]
  end

  def find_nested_form_field(attribute, visible: :visible)
    current_scope.find(nested_form_field_selector(attribute), visible:)
  end

  def have_nested_field(attribute, with:)
    have_field find_nested_form_field_locator(attribute), with:
  end

  def have_no_nested_field(attribute, with:)
    have_no_field(find_nested_form_field_locator(attribute), with:)
  end

  def nested_form_field_selector(attribute)
    "[id$=#{attribute}]"
  end

  def within_add_display_condition
    within ".questionnaire-question:last-of-type" do
      click_button "Add display condition"

      within ".questionnaire-question-display-condition:last-of-type" do
        yield
      end
    end
  end

  def expand_all_questions
    find(".button.expand-all").click
  end

  def visit_questionnaire_edit_path_and_expand_all
    visit questionnaire_edit_path
    expand_all_questions
  end
end
