# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    ParticipatoryProcessesMetricInterface = GraphQL::InterfaceType.define do
      name "ParticipatoryProcessesMetricInterface"
      description "ParticipatoryProcessesMetric definition"

      field :count, !types.Int, "Total participatory processes" do
        resolve ->(organization, _args, _ctx) {
          ParticipatoryProcessesMetricTypeHelper.base_scope(organization, :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          ParticipatoryProcessesMetricTypeHelper.base_scope(organization, :metric)
        }
      end

      field :data, !types[ParticipatoryProcessesMetricObjectType], "Data for each participatory process" do
        resolve ->(organization, _args, _ctx) {
          ParticipatoryProcessesMetricTypeHelper.base_scope(organization, :data)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
