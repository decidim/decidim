# frozen_string_literal: true

module Decidim
  module Assemblies
    AssembliesMetricInterface = GraphQL::InterfaceType.define do
      name "AssembliesMetricInterface"
      description "AssembliesMetric definition"

      field :count, !types.Int, "Total assemblies" do
        resolve ->(organization, _args, _ctx) {
          AssembliesMetricTypeHelper.base_scope(organization, :count)
        }
      end

      field :metric, !types[Decidim::Core::MetricObjectType], "Metric data" do
        resolve ->(organization, _args, _ctx) {
          AssembliesMetricTypeHelper.base_scope(organization, :metric)
        }
      end

      field :data, !types[AssembliesMetricObjectType], "Data for each assembly" do
        resolve ->(organization, _args, _ctx) {
          AssembliesMetricTypeHelper.base_scope(organization, :data)
        }
      end

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
