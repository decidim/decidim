# frozen_string_literal: true

module Decidim
  module Templates
    # All the business logic to duplicate a questionnaire
    module Admin
      module QuestionnaireCopier
        def copy_questionnaire_questions(original_questionnaire, new_questionnaire)
          # start by copying the questions so that they already exist when cross referencing them in the conditions
          original_questionnaire.questions.each do |original_question|
            new_question = original_question.dup
            new_question.questionnaire = new_questionnaire
            new_question.save!
            copy_questionnaire_answer_options(original_question, new_question)
            copy_questionnaire_matrix_rows(original_question, new_question)
          end
          original_questionnaire.questions.zip(new_questionnaire.questions).each do |original_question, new_question|
            copy_question_display_conditions(original_question, new_question)
          end
        end

        def copy_questionnaire_answer_options(original_question, new_question)
          original_question.answer_options.each do |original_answer_option|
            new_answer_option = original_answer_option.dup
            new_answer_option.question = new_question
            new_answer_option.save!
          end
        end

        def copy_questionnaire_matrix_rows(original_question, new_question)
          original_question.matrix_rows.each do |original_matrix_row|
            new_matrix_row = original_matrix_row.dup
            new_matrix_row.question = new_question
            new_matrix_row.save!
          end
        end

        def copy_question_display_conditions(original_question, destination_question)
          original_question.display_conditions.each do |original_display_condition|
            new_display_condition = original_display_condition.dup
            new_display_condition.question = destination_question
            destination_question_to_be_checked = destination_question.questionnaire.questions.find_by(position: original_display_condition.condition_question.position)
            new_display_condition.condition_question = destination_question_to_be_checked
            if original_display_condition.answer_option
              new_display_condition.answer_option = destination_question_to_be_checked.answer_options.find_by(body: original_display_condition.answer_option.body)
            end
            new_display_condition.save!
          end
        end
      end
    end
  end
end
