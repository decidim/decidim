# frozen_string_literal: true

module Decidim
  module Accountability
    class AccountabilityMutationType < Decidim::Core::ComponentType
      graphql_name "AccountabilityMutation"
      description "Accountability mutations"

      field :create_result, mutation: CreateResultType, description: "create result"
      field :result, ResultMutationType, "A single Result object", null: true do
        argument :id, GraphQL::Types::ID, description: "id of the result", required: true
      end

      def result(id:)
        Result.where(component: object).find(id)
      end
    end
  end
end
