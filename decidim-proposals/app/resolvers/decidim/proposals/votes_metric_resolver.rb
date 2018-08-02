# frozen_string_literal: true

module Decidim
  module Proposals
    # A GraphQL resolver to handle `count` and `metric` queries
    class VotesMetricResolver < Decidim::Core::MetricResolver
      def initialize(organization)
        super(organization)
        @metric_counter = Decidim::Proposals::Metrics::VotesMetricCount.for(@organization)
      end
    end
  end
end
