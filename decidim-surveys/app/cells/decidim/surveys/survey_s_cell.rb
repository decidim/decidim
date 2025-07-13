# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Surveys
    # This cell renders the Search (:s) survey card
    # for a given instance of a Survey
    class SurveySCell < Decidim::CardSCell
      private

      def title
        present(model).title(html_escape: true)
      end

      def metadata_cell
        "decidim/surveys/survey_card_metadata"
      end
    end
  end
end
