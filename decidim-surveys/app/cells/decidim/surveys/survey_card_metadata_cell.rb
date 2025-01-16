# frozen_string_literal: true

module Decidim
  module Surveys
    # This cell renders metadata for an instance of a Survey
    class SurveyCardMetadataCell < Decidim::CardMetadataCell
      include Decidim::LayoutHelper
      include ActionView::Helpers::DateHelper

      alias survey model

      def initialize(*)
        super

        @items.prepend(*survey_items)
      end

      private

      def survey_items
        [duration, questions_count_item]
      end

      def survey_items_for_map
        [duration, questions_count_item].compact_blank.map do |item|
          {
            text: item[:text].to_s.html_safe,
            icon: item[:icon].present? ? icon(item[:icon]).html_safe : nil
          }
        end
      end

      def duration
        text = survey.open? ? t("open", scope: "decidim.surveys.surveys.show") : t("closed", scope: "decidim.surveys.surveys.show")

        {
          text:,
          icon: "time-line"
        }
      end

      def questions_count_item
        text = "#{survey.questionnaire.questions.size} #{t("questions", scope: "decidim.surveys.surveys.show")}"

        {
          text:,
          icon: "survey-line"
        }
      end
    end
  end
end
