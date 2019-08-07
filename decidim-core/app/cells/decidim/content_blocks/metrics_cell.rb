# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class MetricsCell < Decidim::ViewModel
      def show
        return unless current_organization.show_statistics?

        render
      end

      def metrics
        @metrics ||= MetricChartsPresenter.new(organization: current_organization)
      end
    end
  end
end
