# frozen_string_literal: true

module Decidim
  module Admin
    class DashboardMetricChartsPresenter < Decidim::MetricChartsPresenter
      def summary?
        __getobj__.fetch(:summary)
      end

      def highlighted_metrics
        return super unless summary?

        Decidim.metrics_registry.filtered(
          highlight: true,
          scope: "home"
        ).select do |registry|
          %w(users proposals).include? registry.metric_name
        end
      end

      def not_highlighted_metrics
        return super unless summary?

        Decidim.metrics_registry.filtered(
          highlight: false,
          scope: "home"
        ).select do |registry|
          %w(comments meetings accepted_proposals results blocked_users user_reports reported_users).include? registry.metric_name
        end
      end
    end
  end
end
