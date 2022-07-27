# frozen_string_literal: true

require "spec_helper"

shared_examples_for "update display conditions" do
  context "when loading a saved display condition" do
    let!(:condition_question_type) { "short_answer" }
    let!(:condition_question) { create(:questionnaire_question, questionnaire:, question_type: condition_question_type, position: 1) }
    let!(:question) { create(:questionnaire_question, questionnaire:, question_type: "short_answer", position: 2) }
    let!(:condition_type) { :answered }
    let!(:answer_option) { nil }

    let!(:display_condition) do
      create(:display_condition,
             question:,
             condition_question:,
             condition_type:,
             answer_option:)
    end

    before do
      visit_questionnaire_edit_path_and_expand_all
    end

    it "the related form appears" do
      expect(page).to have_selector(".questionnaire-question-display-condition")
    end

    it "loads condition_question in select" do
      within ".questionnaire-question-display-condition" do
        expect(page).to have_select("Question", selected: condition_question.body["en"])
      end
    end

    it "loads condition_type in select" do
      within ".questionnaire-question-display-condition" do
        expect(page).to have_select("Condition", selected: "Answered")
      end
    end

    context "when condition_type is :equal" do
      let!(:condition_question_type) { "single_option" }
      let!(:answer_options) { create_list(:answer_option, 3, question: condition_question) }
      let!(:answer_option) { answer_options.third }
      let!(:condition_type) { :equal }

      it "loads answer_option in select" do
        within ".questionnaire-question-display-condition" do
          expect(page).to have_select("Condition", selected: "Equal")
          expect(page).to have_select("Answer option", selected: answer_option.body["en"])
        end
      end
    end

    it "can be removed" do
      within ".questionnaire-question-display-condition:last-of-type" do
        click_button "Remove"
      end

      click_button "Save"

      visit_questionnaire_edit_path_and_expand_all

      expect(page).to have_selector(".questionnaire-question-display-condition", count: 0)
    end

    it "still removes the question even if previous editions rendered the conditions invalid" do
      within "form.edit_questionnaire" do
        expect(page).to have_selector(".questionnaire-question", count: 2)

        within ".questionnaire-question-display-condition:first-of-type" do
          select condition_question.body["en"], from: "Question"
          select "Includes text", from: "Condition"
          fill_in find_nested_form_field_locator("condition_value_en"), with: ""
        end

        within ".questionnaire-question:last-of-type" do
          click_button "Remove", match: :first
        end

        click_button "Save"
      end

      expect(page).to have_admin_callout("successfully")

      visit_questionnaire_edit_path_and_expand_all

      within "form.edit_questionnaire" do
        expect(page).to have_selector(".questionnaire-question", count: 1)
      end
    end
  end
end
