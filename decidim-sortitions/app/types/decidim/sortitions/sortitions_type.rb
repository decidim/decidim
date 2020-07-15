# frozen_string_literal: true

module Decidim
  module Sortitions
    SortitionsType = GraphQL::ObjectType.define do
      interfaces [-> { Decidim::Core::ComponentInterface }]

      name "Sortitions"
      description "A sortition component of a participatory space."

      connection :sortitions, SortitionType.connection_type do
        resolve ->(component, _args, _ctx) {
                  SortitionTypeHelper.base_scope(component).includes(:component)
                }
      end

      field(:sortition, SortitionType) do
        argument :id, !types.ID

        resolve ->(component, args, _ctx) {
          SortitionTypeHelper.base_scope(component).find_by(id: args[:id])
        }
      end
    end

    module SortitionTypeHelper
      def self.base_scope(component)
        Sortition.where(component: component)
      end
    end
  end
end
