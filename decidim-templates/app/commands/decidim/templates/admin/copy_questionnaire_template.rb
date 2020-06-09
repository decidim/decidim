# frozen_string_literal: true

module Decidim
  module Templates
    # A command with all the business logic when duplicating a new questionnaire template
    module Admin
      class CopyQuestionnaireTemplate < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # questionnaire_template - An questionnaire_template we want to duplicate
        def initialize(questionnaire_template)
          @questionnaire_template = questionnaire_template
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          QuestionnaireTemplate.transaction do
            copy_questionnaire_template
            copy_questionnaire_questions(@questionnaire_template.questionnaire, @copied_questionnaire_template.questionnaire)
          end

          broadcast(:ok, @copied_questionnaire_template)
        end

        private

        attr_reader :form

        def copy_questionnaire_template
          @copied_questionnaire_template = QuestionnaireTemplate.create!(
            organization: @questionnaire_template.organization,
            title: @questionnaire_template.title,
            description: @questionnaire_template.description,
            questionnaire: @questionnaire_template.questionnaire.dup
          )
        end

        def copy_questionnaire_questions(original_questionnaire, new_questionnaire)
          original_questionnaire.questions.each do |original_question|
            new_question = original_question.dup
            new_question.questionnaire = new_questionnaire
            new_question.save!
            copy_questionnaire_answer_options(original_question, new_question)
            copy_questionnaire_matrix_rows(original_question, new_question)
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
      end
    end
  end
end
