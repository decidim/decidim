# frozen_string_literal: true

module Decidim
  module Votings
    module VotingsHelper
      # Returns  options for state filter selector.
      def options_for_state_filter
        [
          ["all", t("votings.filters.all", scope: "decidim.votings")],
          ["active", t("votings.filters.active", scope: "decidim.votings")],
          ["upcoming", t("votings.filters.upcoming", scope: "decidim.votings")],
          ["finished", t("votings.filters.finished", scope: "decidim.votings")]
        ]
      end
    end
  end
end
