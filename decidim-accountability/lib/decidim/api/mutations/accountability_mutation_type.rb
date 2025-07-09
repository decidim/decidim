# frozen_string_literal: true

module Decidim
  module Accountability
    class AccountabilityMutationType < Decidim::Api::Types::BaseObject
      graphql_name "AccountabilityMutation"
      description "Accountability mutations"

      field :create_result, mutation: CreateResultType, description: "create result"
      field :delete_result, mutation: DeleteResultType, description: "update result"
      field :result_mutation, type: ResultMutationType, description: "A result mutation" do
        argument :id, GraphQL::Types::ID, description: "id of the result", required: true
      end
      field :update_result, mutation: UpdateResultType, description: "update result"

      def result_mutation(**args)
        Result.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
