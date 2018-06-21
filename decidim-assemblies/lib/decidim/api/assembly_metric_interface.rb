# frozen_string_literal: true

module Decidim
  module Assemblies
    AssemblyMetricInterface = GraphQL::InterfaceType.define do
      name "AssemblyMetricInterface"
      description "AssemblyMetric definition"

      field :count, !types.Int, "Total assemblies" do
        resolve ->(organization, _args, _ctx) {
          AssemblyMetricTypeHelper.base_scope(organization).count
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          AssemblyMetricTypeHelper.base_scope(organization).group("date_trunc('day', published_at)").count
        }
      end

      field :data, !types[AssemblyMetricObjectType], "Data for each assembly" do
        resolve ->(organization, _args, _ctx) {
          AssemblyMetricTypeHelper.base_scope(organization)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
