# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the Statistics of a ParticipatoryProcesses
    class StatisticsCell < Decidim::ViewModel
      private

      def stats_heading
        t("statistics.headline", scope: "decidim.participatory_processes")
      end

      def no_stats
        t("statistics.no_stats", scope: "decidim.participatory_processes")
      end
    end
  end
end
