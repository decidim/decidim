# frozen_string_literal: true

module Decidim
  module Proposals
    # A GraphQL resolver to handle `count` and `metric` queries
    class ProposalsMetricResolver < Decidim::Core::MetricResolver
      def initialize(organization)
        super(organization)
        @metric_counter = Decidim::Proposals::Metrics::ProposalsMetricCount.for(@organization)
      end
    end
  end
end
