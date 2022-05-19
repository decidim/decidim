# frozen_string_literal: true

module Decidim
  module Consultations
    # Helper for questions controller
    module QuestionsHelper
      # Returns a link to the next/previous question if found.
      # Else, returns a disabled link to the current question.
      def display_next_previous_button(direction, optional_classes = "")
        # rubocop: disable Style/StringConcatenation as we don't want the string to be frozen
        css = "card__button button hollow " + optional_classes
        # rubocop: enable Style/StringConcatenation

        # Do not show anything if is a lonely question
        return unless previous_published_question || next_published_question

        case direction
        when :previous
          i18n_text = t("previous_button", scope: "decidim.questions")
          question = previous_published_question || current_question
          css << " disabled" if previous_published_question.nil?
        when :next
          i18n_text = t("next_button", scope: "decidim.questions")
          question = next_published_question || current_question
          css << " disabled" if next_published_question.nil?
        end

        link_to(i18n_text, decidim_consultations.question_path(question), class: css)
      end

      def authorized_vote_modal_button(question, html_options, &block)
        return if current_user && action_authorized_to(:vote, resource: nil, permissions_holder: question).ok?

        tag = "button"
        html_options ||= {}

        if current_user
          html_options["data-open"] = "authorizationModal"
          html_options["data-open-url"] = decidim_consultations.authorization_vote_modal_question_path(question)
        else
          html_options["data-open"] = "loginModal"
        end

        html_options["onclick"] = "event.preventDefault();"

        send("#{tag}_to", "", html_options, &block)
      end
    end
  end
end
