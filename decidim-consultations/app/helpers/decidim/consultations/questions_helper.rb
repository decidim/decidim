# frozen_string_literal: true

module Decidim
  module Consultations
    # Helper for questions controller
    module QuestionsHelper
      # Returns a link to the next/previous question if found.
      # Else, returns a disabled link to the current question.
      def display_next_previous_button(direction, optional_classes = "")
        css = "card__button button hollow " + optional_classes

        case direction
        when :previous
          i18n_text = t("previous_button", scope: "decidim.questions")
          question = previous_question || current_question
          css << " disabled" if previous_question.nil?
        when :next
          i18n_text = t("next_button", scope: "decidim.questions")
          question = next_question || current_question
          css << " disabled" if next_question.nil?
        end

        link_to(i18n_text, decidim_consultations.question_path(question), class: css)
      end
    end
  end
end
