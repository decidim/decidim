# frozen_string_literal: true

module Decidim
  module Admin
    class DashboardStatisticChartsPresenter < Decidim::StatsPresenter
      def summary?
        __getobj__.fetch(:summary)
      end

      def scope_entity
        __getobj__.fetch(:organization)
      end

      def highlighted
        high_priority_stats = collection(priority: StatsRegistry::HIGH_PRIORITY)
        medium_priority_stats = collection(priority: StatsRegistry::MEDIUM_PRIORITY)

        (high_priority_stats + medium_priority_stats).uniq
      end

      private

      def published_components
        @published_components ||= scope_entity.published_components
      end
    end
  end
end
