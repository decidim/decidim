# frozen_string_literal: true

require "spec_helper"

shared_examples_for "copies all questionnaire contents" do
  describe "when the questionnaire has all contents" do
    it "copies all template contents to the questionnaire" do
      destination_questionnaire.reload

      check_copy_questionnaire_questions(template.templatable, destination_questionnaire)
    end

    def check_copy_questionnaire_questions(source_questionnaire, new_questionnaire)
      expect(source_questionnaire.questions.size).to eq(new_questionnaire.questions.size)

      source_questionnaire.questions.each_with_index do |source_question, idx|
        new_question = new_questionnaire.questions[idx]

        expect(source_question.position).to eq(new_question.position)
        expect(source_question.question_type).to eq(new_question.question_type)
        expect(source_question.mandatory).to eq(new_question.mandatory)
        expect(source_question.body).to eq(new_question.body)
        expect(source_question.description).to eq(new_question.description)
        expect(source_question.max_choices).to eq(new_question.max_choices)

        check_response_options(source_question, new_question)
        check_matrix_rows(source_question, new_question)
        check_display_conditions(source_question.display_conditions, new_question.display_conditions)
        check_display_conditions(source_question.display_conditions_for_other_questions, new_question.display_conditions_for_other_questions)
      end
    end

    def check_response_options(source_question, new_question)
      expect(source_question.response_options.size).to eq(new_question.response_options.size)

      source_question.response_options.each_with_index do |source_response_option, idx|
        new_response_option = new_question.response_options[idx]

        expect(source_response_option.body).to eq(new_response_option.body)
      end
    end

    def check_matrix_rows(source_question, new_question)
      expect(source_question.matrix_rows.size).to eq(new_question.matrix_rows.size)

      source_question.matrix_rows.each_with_index do |source_matrix_row, idx|
        new_matrix_row = new_question.matrix_rows[idx]

        expect(source_matrix_row.body).to eq(new_matrix_row.body)
        expect(source_matrix_row.position).to eq(new_matrix_row.position)
      end
    end

    def check_display_conditions(source_display_conditions, new_display_conditions)
      expect(source_display_conditions.size).to eq(new_display_conditions.size)

      source_display_conditions.each_with_index do |source_matrix_row, idx|
        new_matrix_row = new_display_conditions[idx]

        expect(source_matrix_row.condition_type).to eq(new_matrix_row.condition_type)
        expect(source_matrix_row.condition_value).to eq(new_matrix_row.condition_value)
        expect(source_matrix_row.mandatory).to eq(new_matrix_row.mandatory)
        expect(new_matrix_row).to be_persisted
      end
    end
  end
end
