# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      #
      # Presenter for questionnaire answer
      #
      class QuestionnaireAnswerPresenter < Rectify::Presenter
        include Decidim::TranslatableAttributes

        attribute :answer, Decidim::Forms::Answer

        def question
          translated_attribute(answer.question.body, organization)
        end

        def body
          return answer.body if answer.body.present?
          return "-" if answer.choices.empty?

          return answer.choices.first if answer.question.question_type == "single_option"

          present_choices
        end

        def separator?
          answer.question.separator?
        end
        
        def matrix?
          answer.question.matrix?
        end

        private

        def organization
          answer.questionnaire.questionnaire_for&.component&.organization
        end

        def choice_body(choice)
          choice.try(:custom_body) || choice.try(:body)
        end

        def present_choices
          if matrix?
            content_tag :dl do
              safe_join(
                answer.choices.map do |c|
                  matrix_row = answer.question.matrix_rows.find_by(id: c.matrix_row.id)
                  safe_join([
                    content_tag(:dt, translated_attribute(matrix_row.body)),
                    content_tag(:dd, choice_body(c))
                  ])
                end
              )
            end
          else
            content_tag :ul do
              safe_join(
                answer.choices.map do |c|
                  content_tag(:li, choice_body(c))
                end
              )
            end
          end
        end
      end
    end
  end
end
