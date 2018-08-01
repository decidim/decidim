# frozen_string_literal: true

module Decidim
  # A GraphQL resolver to handle `count` and `metric` queries
  class UsersMetricResolver
    def initialize(organization)
      @organization = organization
      @metric_counter = Decidim::Metrics::UsersMetricCount.for(@organization)
    end

    def metric
      @metric_counter.metric
    end

    def count
      @metric_counter.count
    end
  end
end
