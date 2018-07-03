# frozen_string_literal: true

module Decidim
  module Assemblies
    AssembliesMetricObjectType = GraphQL::ObjectType.define do
      interfaces [-> { AssembliesMetricObjectInterface }]

      name "AssembliesMetricObjec"
      description "AssembliesMetric object data"
    end
  end
end
