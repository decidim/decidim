# frozen_string_literal: true

module Decidim
  module Assemblies
    AssemblyMetricInterface = GraphQL::InterfaceType.define do
      name "AssemblyMetricInterface"
      description "AssemblyMetric definition"

      field :count, !types.Int, "Total assemblies"

      field :data, !types[AssemblyMetricObjectType], "Data for each assembly"

      resolve_type ->(obj, _ctx) { obj.manifest.query_type.constantize }
    end
  end
end
