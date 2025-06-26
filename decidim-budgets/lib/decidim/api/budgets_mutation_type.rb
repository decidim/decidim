# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetsMutationType < Decidim::Api::Types::BaseObject
      graphql_name "BudgetsMutation"
      description "Budgets of a component."

      field :create_budget, mutation: Decidim::Budgets::CreateBudgetType, description: "creates a budget"
      field :update_budget, mutation: Decidim::Budgets::UpdateBudgetType, description: "update a budget"
    end
  end
end
