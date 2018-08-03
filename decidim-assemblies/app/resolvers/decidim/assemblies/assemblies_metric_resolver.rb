# frozen_string_literal: true

module Decidim
  module Assemblies
    # A GraphQL resolver for Assemblies to handle `count` and `metric` queries
    class AssembliesMetricResolver < Decidim::MetricResolver
      def initialize(organization)
        super(organization)
        @metric_counter = Decidim::Assemblies::Metrics::AssembliesMetricCount.for(@organization)
      end
    end
  end
end
