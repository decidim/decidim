# frozen_string_literal: true

require "spec_helper"

shared_examples_for "update display conditions" do
  context "when loading a saved display condition" do
    let(:display_condition_condition_question) { questions.first }
    let(:display_condition_question) { questions.second }
    let(:condition_type) { :answered }
    let(:answer_option) { nil }

    before do
      within_add_display_condition do
        select display_condition_condition_question.body["en"], from: "Question"
        select condition_type, from: "Condition"
      end

      click_button "Save"

      visit questionnaire_edit_path
    end

    it "the related form appears" do
      expect(page).to have_selector(".questionnaire-question-display-condition")
    end

    it "loads condition_question in select" do
      within ".questionnaire-question-display-condition" do
        expect(page).to have_selected_option(display_condition.condition_question.body["en"])
      end
    end

    it "loads condition_type in select" do
      within ".questionnaire-question-display-condition" do
        expect(page).to have_selected_option("Answered")
      end
    end

    context "when condition_type is :equal" do
      let!(:answer_option) { question_single_option.answer_options.first }
      let!(:display_condition_condition_question) { question_single_option }
      let!(:display_condition_question) { question_multiple_option }
      let!(:condition_type) { :equal }

      it "loads answer_option in select" do
        within ".questionnaire-question-display-condition" do
          expect(page).to have_selected_option("Equal")
          expect(page).to have_selected_option(answer_option.body["en"])
        end
      end
    end
  end

  it "can be removed" do
    within ".questionnaire-question-display-condition:last-of-type" do
      click_button "Remove"
    end

    click_button "Save"

    visit questionnaire_edit_path

    expect(page).to have_selector(".questionnaire-question-display-condition", count: 0)
  end

  it "still removes the question even if previous editions rendered the conditions invalid" do
    within "form.edit_questionnaire" do
      expect(page).to have_selector(".questionnaire-question", count: 1)

      within ".questionnaire-question-display-condition:first-of-type" do
        select question_short_answer, from: "Question"
        select "Includes text", from: "Condition"
        fill_in find_nested_form_field_locator("body_en"), with: ""
      end

      within ".questionnaire-question" do
        click_button "Remove", match: :first
      end

      click_button "Save"
    end

    expect(page).to have_admin_callout("successfully")

    visit questionnaire_edit_path

    within "form.edit_questionnaire" do
      expect(page).to have_selector(".questionnaire-question", count: 0)
    end
  end
end