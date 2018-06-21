# frozen_string_literal: true

module Decidim
  module Assemblies
    AssemblyMetricType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Assemblies::AssemblyMetricInterface }]

      name "AssemblyMetricType"
      description "An assembly component of a participatory space."

      field :count, !types.Int, "Total assemblies" do
        resolve ->(organization, _args, _ctx) {
          AssemblyMetricTypeHelper.base_scope(organization).count
        }
      end

      field :data, !types[AssemblyMetricObjectType], "Data for each assembly" do
        resolve ->(organization, _args, _ctx) {
          AssemblyMetricTypeHelper.base_scope(organization)
        }
      end
    end

    module AssemblyMetricTypeHelper
      def self.base_scope(_organization)
        # super(organization).accepted
        Assembly.includes(:scope, :area).all
      end
    end
  end
end
