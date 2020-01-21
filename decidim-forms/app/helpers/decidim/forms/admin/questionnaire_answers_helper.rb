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

        def questionnaire_participant_status(registered)
          t(registered ? "registered" : "unregistered", scope: "decidim.forms.user_answers_serializer")
        end

        def display_percentage(number)
          number_to_percentage(number, precision: 0, strip_insignificant_zeros: true, locale: I18n.locale)
        end
      end
    end
  end
end
