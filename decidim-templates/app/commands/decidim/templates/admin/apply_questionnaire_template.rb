# frozen_string_literal: true

module Decidim
  module Templates
    # A command with all the business logic when duplicating a questionnaire template
    module Admin
      class ApplyQuestionnaireTemplate < Rectify::Command
        # Public: Initializes the command.
        #
        # template - The template we want to apply
        # questionnaire - The questionnaire we want to use the template
        def initialize(questionnaire, template)
          @questionnaire = questionnaire
          @template = template
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @template && @template.valid?

          Template.transaction do
            apply_template
            copy_questionnaire_questions(@template.templatable, @questionnaire)
          end

          broadcast(:ok, @questionnaire)
        end

        private

        attr_reader :form

        def apply_template
          @questionnaire.update!(
            title: @template.templatable.title,
            description: @template.templatable.description,
            tos: @template.templatable.tos
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
