# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Surveys
    # This cell renders the List (:l) survey card
    # for a given instance of a Survey
    class SurveyLCell < Decidim::CardLCell
      include Decidim::SanitizeHelper

      def has_description?
        true
      end

      def title
        decidim_sanitize_translated(model.title)
      end

      def description
        attribute = model.try(:short_description) || model.try(:body) || model.description
        text = translated_attribute(attribute)

        decidim_sanitize(html_truncate(text, length: 240), strip_tags: true)
      end

      private

      def metadata_cell
        "decidim/surveys/survey_card_metadata"
      end
    end
  end
end
