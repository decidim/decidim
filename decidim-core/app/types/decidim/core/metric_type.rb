# frozen_string_literal: true

module Decidim
  module Core
    MetricType = GraphQL::ObjectType.define do
      name "MetricType"
      description "Metric data"

      field :name, !types.String, "The name of the metric"
      field :count, !types.Int, "The last value of the metric"
      field :history, !types[MetricHistoryType], "The historic values for this metric"
    end
  end
end
