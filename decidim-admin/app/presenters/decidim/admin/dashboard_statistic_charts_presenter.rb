# frozen_string_literal: true

module Decidim
  module Admin
    class DashboardStatisticChartsPresenter < Decidim::StatsPresenter
      def summary?
        __getobj__.fetch(:summary)
      end

      def highlighted_statistics; end

      def not_highlighted_statistics; end
    end
  end
end
