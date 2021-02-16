# frozen_string_literal: true

module Decidim
  module Votings
    module VotingsHelper
      include Decidim::CheckBoxesTreeHelper

      def filter_states_values
        TreeNode.new(
          TreePoint.new("", t("votings.filters.all", scope: "decidim.votings")),
          [
            TreePoint.new("active", t("votings.filters.active", scope: "decidim.votings")),
            TreePoint.new("upcoming", t("votings.filters.upcoming", scope: "decidim.votings")),
            TreePoint.new("finished", t("votings.filters.finished", scope: "decidim.votings"))
          ]
        )
      end
    end
  end
end
