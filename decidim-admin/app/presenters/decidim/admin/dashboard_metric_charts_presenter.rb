# frozen_string_literal: true

module Decidim
  module Admin
    class DashboardMetricChartsPresenter < Decidim::MetricChartsPresenter
      attribute :summary, Boolean

      def render_not_highlighted(metrics)
        safe_join(
          metrics.map do |metric|
            render_metrics_data(metric.metric_name, klass: not_highlighted_classes, graph_klass: "small")
          end
        )
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

      private

      def highlighted_classes
        return "cell medium-6" if summary?

        "cell medium-4"
      end

      def not_highlighted_classes
        return "cell medium-3" if summary?

        "cell medium-2"
      end

      def not_highlighted_wrapper_classes
        "grid-x grid-margin-x"
      end
    end
  end
end
