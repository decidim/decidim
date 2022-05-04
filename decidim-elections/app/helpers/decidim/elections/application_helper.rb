# frozen_string_literal: true

module Decidim
  module Elections
    # Custom helpers, scoped to the elections engine.
    #
    module ApplicationHelper
      include Decidim::CheckBoxesTreeHelper

      def date_filter_values
        TreeNode.new(
          TreePoint.new("", t("elections.elections.filters.all", scope: "decidim")),
          [
            TreePoint.new("active", t("elections.elections.filters.active", scope: "decidim")),
            TreePoint.new("upcoming", t("elections.elections.filters.upcoming", scope: "decidim")),
            TreePoint.new("finished", t("elections.elections.filters.finished", scope: "decidim"))
          ]
        )
      end
    end
  end
end
