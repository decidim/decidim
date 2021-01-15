# frozen_string_literal: true

module Decidim
  module Sortitions
    class SortitionsType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Sortitions"
      description "A sortition component of a participatory space."

      field :sortitions, SortitionType.connection_type, null: true, connection: true

      def sortitions
        SortitionTypeHelper.base_scope(object).includes(:component)
      end

      field :sortition, SortitionType, null: true do
        argument :id, ID, required: true
      end

      def sortition(**args)
        SortitionTypeHelper.base_scope(object).find_by(id: args[:id])
      end
    end

    module SortitionTypeHelper
      def self.base_scope(component)
        Sortition.where(component: component)
      end
    end
  end
end
