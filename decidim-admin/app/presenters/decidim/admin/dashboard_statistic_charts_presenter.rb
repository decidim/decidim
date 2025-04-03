# frozen_string_literal: true

module Decidim
  module Admin
    class DashboardStatisticChartsPresenter < Decidim::StatsPresenter
      def scope_entity
        __getobj__.fetch(:organization)
      end

      def highlighted
        high_priority_stats = collection(priority: StatsRegistry::HIGH_PRIORITY)
        medium_priority_stats = collection(priority: StatsRegistry::MEDIUM_PRIORITY)

        filtered_high_priority = high_priority_stats.reject { |stat| duplicated_stat?(stat) }

        (filtered_high_priority + medium_priority_stats).uniq
      end

      private

      def duplicated_stat?(stat)
        [:proposals_count, :meetings_count].include?(stat[:name].to_sym)
      end
    end
  end
end
