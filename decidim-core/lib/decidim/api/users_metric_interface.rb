# frozen_string_literal: true

module Decidim
  module Core
    UsersMetricInterface = GraphQL::InterfaceType.define do
      name "UsersMetricInterface"
      description "UsersMetric definition"

      field :count, !types.Int, "Total users"

      field :metric, !types[MetricObjectType], "Metric data"
    end
  end
end
