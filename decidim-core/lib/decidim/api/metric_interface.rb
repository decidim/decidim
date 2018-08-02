# frozen_string_literal: true

module Decidim
  module Core
    MetricInterface = GraphQL::InterfaceType.define do
      name "MetricInterface"
      description "Metric definition"

      field :count, !types.Int, "Total registries"

      field :metric, !types[MetricObjectType], "Metric data"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
