# frozen_string_literal: true

module Decidim
  module Meetings
    # A GraphQL resolver to handle `count` and `metric` queries
    class MeetingsMetricResolver < Decidim::MetricResolver
      def initialize(organization)
        super(organization)
        @metric_counter = Decidim::Meetings::Metrics::MeetingsMetricCount.for(@organization)
      end
    end
  end
end
