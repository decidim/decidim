# frozen_string_literal: true

module Decidim
  module Accountability
    class AccountabilityMutationType < Decidim::Core::ComponentType
      graphql_name "AccountabilityMutation"
      description "Accountability mutations for a component."

      field :create_result, mutation: CreateResultType, description: "Creates a result"
      field :result, ResultMutationType, "Mutates a result", null: true do
        argument :id, GraphQL::Types::ID, description: "The ID of the result", required: true
      end

      def result(id:)
        Result.where(component: object).find(id)
      end
    end
  end
end
