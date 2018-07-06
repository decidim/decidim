# frozen_string_literal: true

module Decidim
  module Core
    UsersMetricInterface = GraphQL::InterfaceType.define do
      name "UsersMetricInterface"
      description "UsersMetric definition"

      field :count, !types.Int, "Total users" do
        resolve ->(_obj, _args, ctx) {
          UsersMetricTypeHelper.base_scope(ctx[:current_organization], :count)
        }
      end

      field :metric, !types[MetricObjectType], "Metric data" do
        resolve ->(_obj, _args, ctx) {
          UsersMetricTypeHelper.base_scope(ctx[:current_organization], :metric)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
