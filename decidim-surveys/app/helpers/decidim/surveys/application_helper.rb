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
        [
          ["all", t("all", scope: "decidim.surveys.surveys.filters")],
          ["open", { checked: true }, t("open", scope: "decidim.surveys.surveys.filters.state_values")],
          ["closed", t("closed", scope: "decidim.surveys.surveys.filters.state_values")]
        ]
      end

      def filter_sections
        @filter_sections ||= [{
          method: :with_any_state,
          collection: filter_surveys_date_values,
          label: t("decidim.proposals.proposals.filters.state"),
          id: "state",
          type: :radio_buttons
        }]
      end
    end
  end
end
