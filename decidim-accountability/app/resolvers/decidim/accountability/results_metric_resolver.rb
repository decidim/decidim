# frozen_string_literal: true

module Decidim
  module Accountability
    # A GraphQL resolver for Accountability's results to handle `count` and `metric` queries
    class ResultsMetricResolver < Decidim::Core::MetricResolver
      def initialize(organization)
        super(organization)
        @metric_counter = Decidim::Accountability::Metrics::ResultsMetricCount.for(@organization)
      end
    end
  end
end
