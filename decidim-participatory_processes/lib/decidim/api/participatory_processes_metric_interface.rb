# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    ParticipatoryProcessesMetricInterface = GraphQL::InterfaceType.define do
      name "ParticipatoryProcessesMetricInterface"
      description "ParticipatoryProcessesMetric definition"

      field :count, !types.Int, "Total participatory processes" do
        resolve ->(_obj, _args, ctx) {
          ParticipatoryProcessesMetricTypeHelper.base_scope(ctx[:current_organization], :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(_obj, _args, ctx) {
          ParticipatoryProcessesMetricTypeHelper.base_scope(ctx[:current_organization], :metric)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
