# frozen_string_literal: true

module Decidim
  module Elections
    # Custom helpers, scoped to the elections engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::DateRangeHelper
      include Decidim::CheckBoxesTreeHelper

      # Returns a TreeNode to be used in the list filters to filter elections by
      # its state.
      def filter_elections_state_values
        %w(scheduled ongoing finished results_published).map { |k| [k, t(k, scope: "decidim.elections.elections.filters.state_values")] }.prepend(
          ["all", t("all", scope: "decidim.elections.elections.filters")]
        )
      end

      def filter_sections
        @filter_sections ||= begin
          items = [{
            method: :with_any_state,
            collection: filter_elections_state_values,
            label: t("decidim.elections.elections.filters.state"),
            id: "date",
            type: :radio_buttons
          }]

          items.reject { |item| item[:collection].blank? }
        end
      end

      def search_variable = :search_text_cont

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.components.elections.name")
      end

      def question_title(question)
        content_tag(:h2, class: "h4") do
          concat content_tag(:span, question.position.next, data: { "question-position" => true })
          concat " - "
          concat content_tag(:span, translated_attribute(question.body), data: { "question-body" => true })
        end
      end

      def selected_response_option_id(question)
        session.dig(:votes_buffer, question.id.to_s, "response_option_id")&.to_i
      end

      def voted_by_current_user?(election)
        voter_uid = session[:voter_uid] || election.census.voter_uid(current_user)
        election.votes.exists?(voter_uid:)
      end
    end
  end
end
