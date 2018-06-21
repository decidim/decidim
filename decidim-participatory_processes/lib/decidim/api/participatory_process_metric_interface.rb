# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    ParticipatoryProcessMetricInterface = GraphQL::InterfaceType.define do
      name "ParticipatoryProcessMetricInterface"
      description "ParticipatoryProcessMetric definition"

      field :count, !types.Int, "Total participatory processes" do
        resolve ->(organization, _args, _ctx) {
          ParticipatoryProcessMetricTypeHelper.base_scope(organization).count
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          ParticipatoryProcessMetricTypeHelper.base_scope(organization).group("date_trunc('day', published_at)").count
        }
      end

      field :data, !types[ParticipatoryProcessMetricObjectType], "Data for each participatory process" do
        resolve ->(organization, _args, _ctx) {
          ParticipatoryProcessMetricTypeHelper.base_scope(organization)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
