# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # Custom helpers for questionnaire answers
      #
      module QuestionnaireAnswersHelper
        def questionnaire_answer_body(answer)
          return answer.body if answer.body.present?
          return "-" if answer.choices.empty?

          choices = answer.choices.map do |choice|
            choice.try(:custom_body) || choice.try(:body)
          end

          choices.join(", ")
        end

        def questionnaire_answer_user_status(user_id)
          scope = "decidim.forms.user_answers_serializer"
          t(user_id.present? ? "registered" : "unregistered", scope: scope)
        end
      end
    end
  end
end
