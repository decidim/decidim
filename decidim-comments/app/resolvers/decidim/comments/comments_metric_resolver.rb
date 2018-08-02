# frozen_string_literal: true

module Decidim
  module Comments
    # A GraphQL resolver to handle `count` and `metric` queries
    class CommentsMetricResolver < Decidim::Core::MetricResolver
      def initialize(organization)
        super(organization)
        @metric_counter = Decidim::Comments::Metrics::CommentsMetricCount.for(@organization)
      end
    end
  end
end
