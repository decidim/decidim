# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # Custom helpers for questionnaire answers
      #
      module QuestionnaireAnswersHelper
        def first_table_th(answer)
          return translated_attribute answer.first_short_answer.question.body if answer.first_short_answer

          t("session_token", scope: "decidim.forms.user_answers_serializer")
        end

        def first_table_td(answer)
          return answer.first_short_answer.body if answer.first_short_answer

          answer.session_token
        end

        def display_percentage(number)
          number_to_percentage(number, precision: 0, strip_insignificant_zeros: true, locale: I18n.locale)
        end
      end
    end
  end
end
