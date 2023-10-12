# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceMetricsCell < BaseCell
      def show
        return if metrics.blank?

        render
      end

      private

      def metrics; end

      def scope; end

      def show_all_path; end

      def metrics_count
        Decidim.metrics_registry.filtered(scope:).length
      end

      def highlighted_metrics
        return if metrics.blank?

        metrics.render_charts Decidim.metrics_registry.filtered(highlight: true, scope:)
      end

      def not_highlighted_metrics
        return if metrics.blank?

        metrics.render_charts Decidim.metrics_registry.filtered(highlight: false, scope:)
      end

      def display_not_highlighted_metrics = false

      def data
        { metrics: "" }
      end
    end
  end
end
