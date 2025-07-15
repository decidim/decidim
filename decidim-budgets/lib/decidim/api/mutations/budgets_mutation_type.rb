# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetsMutationType < Decidim::Api::Types::BaseObject
      graphql_name "BudgetsMutation"
      description "Budgets of a component."

      field :budget_mutation, type: Decidim::Budgets::BudgetMutationType, description: "A budget mutation" do
        argument :id, GraphQL::Types::ID, description: "id of the budget", required: true
      end
      field :create_budget, mutation: Decidim::Budgets::CreateBudgetType, description: "creates a budget"
      field :delete_budget, mutation: Decidim::Budgets::DeleteBudgetType, description: "delete a budget"
      field :update_budget, mutation: Decidim::Budgets::UpdateBudgetType, description: "update a budget"

      def budget(**args)
        Budget.where(component: object).find_by(id: args[:id])
      end
    end
  end
end
