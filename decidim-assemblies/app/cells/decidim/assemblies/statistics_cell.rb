# frozen_string_literal: true

module Decidim
  module Assemblies
    # This cell renders the Statistics of an Assembly
    class StatisticsCell < Decidim::ViewModel
      private

      def stats_heading
        t("statistics.headline", scope: "decidim.assemblies")
      end

      def no_stats
        t("statistics.no_stats", scope: "decidim.assemblies")
      end
    end
  end
end
