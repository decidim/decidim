# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetsMutationType < Decidim::Core::ComponentType
      graphql_name "BudgetsMutation"
      description "Budgets of a component"

      field :budget, type: Decidim::Budgets::BudgetMutationType, description: "Mutates a budget", null: true do
        argument :id, GraphQL::Types::ID, "The ID of the budget", required: true
      end
      field :create_budget, mutation: Decidim::Budgets::CreateBudgetType, description: "creates a budget"

      def budget(id:)
        Budget.where(component: object).find(id)
      end
    end
  end
end
