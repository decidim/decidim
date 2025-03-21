# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # Custom helpers for questionnaire responses
      #
      module QuestionnaireResponsesHelper
        def first_table_th(response)
          return nil if response.nil?

          if response.first_short_response
            @first_short_response = response.first_short_response
            return translated_attribute @first_short_response.question.body
          end

          t("session_token", scope: "decidim.forms.user_responses_serializer")
        end

        def first_table_td(response)
          return response.first_short_response&.body if @first_short_response

          response.session_token
        end

        def display_percentage(number)
          number_to_percentage(number, precision: 0, strip_insignificant_zeros: true, locale: I18n.locale)
        end
      end
    end
  end
end
