# frozen_string_literal: true

module Decidim
  # A GraphQL resolver to handle `count` and `metric` queries
  class UsersMetricResolver < Decidim::MetricResolver
    def initialize(organization)
      super(organization)
      @metric_counter = Decidim::Metrics::UsersMetricCount.for(@organization)
    end
  end
end
