# frozen_string_literal: true

module Decidim
  # This cell renders the Statistics of a ParticipatorySpace
  class StatisticsCell < Decidim::ViewModel
    private

    def stats_heading
      t("statistics.headline", scope: "decidim")
    end

    def no_stats
      t("statistics.no_stats", scope: "decidim")
    end
  end
end
