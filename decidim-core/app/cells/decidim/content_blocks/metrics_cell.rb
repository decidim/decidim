# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class MetricsCell < Decidim::ViewModel
      def metrics
        @metrics ||= MetricChartsPresenter.new(organization: current_organization, view_context: view_context)
      end
    end
  end
end
