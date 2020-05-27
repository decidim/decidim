# frozen_string_literal: true

module Decidim
  module Elections
    ElectionsType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Elections"
      description "An elections component of a participatory space."

      connection :elections, ElectionType.connection_type do
        resolve ->(component, _args, _ctx) {
                  ElectionsTypeHelper.base_scope(component).includes(:component)
                }
      end

      field(:election, ElectionType) do
        argument :id, !types.ID

        resolve ->(component, args, _ctx) {
          ElectionsTypeHelper.base_scope(component).find_by(id: args[:id])
        }
      end
    end

    module ElectionsTypeHelper
      def self.base_scope(component)
        Election.where(component: component)
      end
    end
  end
end
