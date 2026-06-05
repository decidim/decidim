# frozen_string_literal: true

module Decidim
  module Surveys
    # This cell renders the proposal card for an instance of a Survey
    # the default size is the Medium Card (:m)
    class SurveyCell < Decidim::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/surveys/survey_l"
      end
    end
  end
end
