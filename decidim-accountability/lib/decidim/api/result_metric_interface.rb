# frozen_string_literal: true

module Decidim
  module Accountability
    ResultMetricInterface = GraphQL::InterfaceType.define do
      name "ResultMetricInterface"
      description "ResultMetric definition"

      field :count, !types.Int, "Total results"

      field :data, !types[ResultMetricObjectType], "Data for each result"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
