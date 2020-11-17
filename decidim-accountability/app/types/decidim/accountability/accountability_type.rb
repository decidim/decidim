# frozen_string_literal: true

module Decidim
  module Accountability
    class AccountabilityType < GraphQL::Schema::Object
      graphql_name "Accountability"
      implements Decidim::Core::ComponentInterface

      description "An accountability component of a participatory space."

      field :results, ResultType.connection_type, null: false do
        def resolve(component, _args, _ctx)
          ResultTypeHelper.base_scope(component).includes(:component)
        end
      end

      field(:result, ResultType, null: true) do
        argument :id, ID, required: true

        def resolve(component, args, _ctx)
          ResultTypeHelper.base_scope(component).find_by(id: args[:id])
        end
      end
    end

    module ResultTypeHelper
      def self.base_scope(component)
        Result.where(component: component)
      end
    end
  end
end
