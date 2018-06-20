# frozen_string_literal: true

module Decidim
  module Assemblies
    AssemblyMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { AssemblyMetricObjectInterface }]

      name "AssemblyMetricObjec"
      description "AssemblyMetric object data"
    end
  end
end
