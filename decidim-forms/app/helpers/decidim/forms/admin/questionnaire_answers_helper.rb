# frozen_string_literal: true

module Decidim
  module Forms
    module Admin
      # Custom helpers for questionnaire answers
      #
      module QuestionnaireAnswersHelper
        def display_percentage(number)
          number_to_percentage(number, precision: 0, strip_insignificant_zeros: true, locale: I18n.locale)
        end
      end
    end
  end
end
