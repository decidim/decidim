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
        %w(scheduled ongoing finished).map { |k| [k, t(k, scope: "decidim.elections.elections.filters.state_values")] }.prepend(
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

      def question_title(question, tag = :h3, **options)
        content_tag(tag, **options) do
          translated_attribute(question.body)
        end
      end
    end
  end
end
