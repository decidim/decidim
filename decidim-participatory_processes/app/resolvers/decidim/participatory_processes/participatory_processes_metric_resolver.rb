# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A GraphQL resolver to handle `count` and `metric` queries
    class ParticipatoryProcessesMetricResolver < Decidim::MetricResolver
      def initialize(organization)
        super(organization)
        @metric_counter = Decidim::ParticipatoryProcesses::Metrics::ParticipatoryProcessesMetricCount.for(@organization)
      end
    end
  end
end
