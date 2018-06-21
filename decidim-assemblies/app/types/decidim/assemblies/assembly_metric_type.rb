# frozen_string_literal: true

module Decidim
  module Assemblies
    AssemblyMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Assemblies::AssemblyMetricInterface }]

      name "AssemblyMetricType"
      description "An assembly component of a participatory space."
    end

    module AssemblyMetricTypeHelper
      def self.base_scope(_organization)
        # super(organization).accepted
        Assembly.includes(:scope, :area).all
      end
    end
  end
end
