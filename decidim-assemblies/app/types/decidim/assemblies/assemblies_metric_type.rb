# frozen_string_literal: true

module Decidim
  module Assemblies
    AssembliesMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::MetricInterface }]

      name "AssembliesMetricType"
      description "An assembly component of a participatory space."
    end
  end
end
