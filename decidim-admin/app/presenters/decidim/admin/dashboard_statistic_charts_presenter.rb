# frozen_string_literal: true

module Decidim
  module Admin
    class DashboardStatisticChartsPresenter < Decidim::StatsPresenter
      def scope_entity
        __getobj__.fetch(:organization)
      end

      def highlighted
        high_priority = collection(priority: StatsRegistry::HIGH_PRIORITY)
        medium_priority = collection(priority: StatsRegistry::MEDIUM_PRIORITY)

        (high_priority + medium_priority).select { |stat| stat[:admin] }
      end
    end
  end
end
