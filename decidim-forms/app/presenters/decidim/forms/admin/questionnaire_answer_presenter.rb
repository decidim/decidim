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

          choices = answer.choices.map do |choice|
            choice.try(:custom_body) || choice.try(:body)
          end

          return choices.first if answer.question.question_type == "single_option"

          content_tag(:ul) do
            safe_join(choices.map { |c| choice(c) })
          end
        end

        private

        def organization
          answer.questionnaire.questionnaire_for&.component&.organization
        end

        def choice(choice_body)
          content_tag :li do
            choice_body
          end
        end
      end
    end
  end
end
