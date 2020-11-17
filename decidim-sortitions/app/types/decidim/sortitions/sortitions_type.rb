# frozen_string_literal: true

module Decidim
  module Sortitions
    class SortitionsType < GraphQL::Schema::Object
      graphql_name "Sortitions"
      implements Decidim::Core::ComponentInterface

      description "A sortition component of a participatory space."

      field :sortitions, SortitionType.connection_type, null: false do
        def resolve(component, _args, _ctx)
          SortitionTypeHelper.base_scope(component).includes(:component)
        end
      end

      field(:sortition, SortitionType, null: true) do
        argument :id, ID, required: true

        def resolve(component, args, _ctx)
          SortitionTypeHelper.base_scope(component).find_by(id: args[:id])
        end
      end
    end

    module SortitionTypeHelper
      def self.base_scope(component)
        Sortition.where(component: component)
      end
    end
  end
end
