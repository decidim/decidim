# frozen_string_literal: true

module Decidim
  module Consultations
    # Helper for questions controller
    module QuestionsHelper
      # Returns a link to the next/previous question
      # depending on whether the user has voted it or not.
      def display_next_previous_button(direction, optional_classes = "")
        css = "card__button button hollow " + optional_classes

        case direction
        when :previous
          i18n_text = t("previous_button", scope: "decidim.questions")
          url = decidim_consultations.question_path(previous_question || current_question)
          css << " disabled" if previous_question.blank?
        when :next
          i18n_text = t("next_button", scope: "decidim.questions")
          url = decidim_consultations.question_path(next_question || current_question)
          css << " disabled" if next_question.blank?
        end

        link_to(i18n_text, url, class: css)
      end
    end
  end
end
