# frozen_string_literal: true

module Decidim
  module Sortitions
    class SortitionsType < Decidim::Core::ComponentType
      graphql_name "Sortitions"
      description "A sortition component of a participatory space."

      field :sortition, Decidim::Sortitions::SortitionType, "A single Sortition object", null: true do
        argument :id, GraphQL::Types::ID, "The id of the Sortition requested", required: true
      end
      field :sortitions, Decidim::Sortitions::SortitionType.connection_type, "A collection of Sortitions", null: true, connection: true

      def sortitions
        Sortition.where(component: object).includes(:component)
      end

      def sortition(**args)
        Sortition.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
