# frozen_string_literal: true

module Decidim
  module Assemblies
    AssembliesMetricInterface = GraphQL::InterfaceType.define do
      name "AssembliesMetricInterface"
      description "AssembliesMetric definition"

      field :count, !types.Int, "Total assemblies" do
        resolve ->(_obj, _args, ctx) {
          AssembliesMetricTypeHelper.base_scope(ctx[:current_organization], :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(_obj, _args, ctx) {
          AssembliesMetricTypeHelper.base_scope(ctx[:current_organization], :metric)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
