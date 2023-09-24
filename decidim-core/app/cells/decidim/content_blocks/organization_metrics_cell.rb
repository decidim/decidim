# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class OrganizationMetricsCell < Decidim::ContentBlocks::ParticipatorySpaceMetricsCell
      private

      def metrics
        @metrics ||= MetricChartsPresenter.new(organization: current_organization)
      end

      def scope
        "home"
      end

      def display_not_highlighted_metrics
        true
      end
    end
  end
end
