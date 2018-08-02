# frozen_string_literal: true

module Decidim
  # A GraphQL resolver to handle `count` and `metric` queries
  class MetricResolver
    def initialize(organization)
      @organization = organization
      @metric_counter = nil
    end

    def metric
      @metric_counter.metric
    end

    def count
      @metric_counter.count
    end
  end
end
