# frozen_string_literal: true

module Decidim
  module Surveys
    # Custom helpers, scoped to the surveys engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::SanitizeHelper
      include Decidim::CheckBoxesTreeHelper
      include Decidim::RichTextEditorHelper

      # Returns a TreeNode to be used in the list filters to filter surveys by
      # its state.
      def filter_surveys_date_values
        %w(open closed).map { |k| [k, t(k, scope: "decidim.surveys.surveys.filters.state_values")] }.prepend(
          ["all", all_filter_text]
        )
      end

      def all_filter_text
        t("all", scope: "decidim.surveys.surveys.filters")
      end

      def filter_sections
        @filter_sections ||= [{
          method: :with_any_state,
          collection: filter_surveys_date_values,
          label_scope: "decidim.surveys.surveys.filters",
          id: "date",
          type: :radio_buttons
        }]
      end
    end
  end
end
