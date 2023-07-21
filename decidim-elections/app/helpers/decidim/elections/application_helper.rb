# frozen_string_literal: true

module Decidim
  module Elections
    # Custom helpers, scoped to the elections engine.
    #
    module ApplicationHelper
      include Decidim::CheckBoxesTreeHelper

      def date_filter_values
        TreeNode.new(
          TreePoint.new("", filter_text_for(t("elections.elections.filters.all", scope: "decidim"))),
          [
            TreePoint.new("active", filter_text_for(t("elections.elections.filters.active", scope: "decidim"))),
            TreePoint.new("upcoming", filter_text_for(t("elections.elections.filters.upcoming", scope: "decidim"))),
            TreePoint.new("finished", filter_text_for(t("elections.elections.filters.finished", scope: "decidim")))
          ]
        )
      end

      def filter_sections
        @filter_sections ||= [{ method: :with_any_date, collection: date_filter_values, label_scope: "decidim.elections.elections.filters", id: "date" }]
      end
    end
  end
end
