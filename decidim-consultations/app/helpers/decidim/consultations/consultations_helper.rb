# frozen_string_literal: true

module Decidim
  module Consultations
    module ConsultationsHelper
      # Returns  options for state filter selector.
      def options_for_state_filter
        [
          ["all", t("consultations.filters.all", scope: "decidim")],
          ["active", t("consultations.filters.active", scope: "decidim")],
          ["upcoming", t("consultations.filters.upcoming", scope: "decidim")],
          ["finished", t("consultations.filters.finished", scope: "decidim")]
        ]
      end
    end
  end
end
