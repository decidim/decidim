# frozen_string_literal: true

module Decidim
  module Admin
    class DashboardStatisticChartsPresenter < Decidim::StatsPresenter
      def scope_entity
        __getobj__.fetch(:organization)
      end

      def highlighted
        stats_by_title = {}

        collection(priority: StatsRegistry::MEDIUM_PRIORITY).each do |stat|
          title = translate_stat_title(stat)
          stats_by_title[title] = { stat: stat, priority: 2 }
        end

        collection(priority: StatsRegistry::HIGH_PRIORITY).each do |stat|
          title = translate_stat_title(stat)
          stats_by_title[title] ||= { stat: stat, priority: 1 }
        end

        stats_by_title.values.sort_by { |entry| entry[:priority] }.map { |entry| entry[:stat] }
      end

      private

      def translate_stat_title(stat)
        I18n.t(stat[:name], scope: "decidim.statistics")
      end
    end
  end
end
