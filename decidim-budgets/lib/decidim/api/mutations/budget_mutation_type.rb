# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetMutationType < Decidim::Api::Types::BaseObject
      description "Budget mutation"
      graphql_name "BudgetMutation"

      field :delete, mutation: Decidim::Budgets::DeleteBudgetType, description: "Deletes a budget"
      field :update, mutation: Decidim::Budgets::UpdateBudgetType, description: "Updates a budget"

      field :create_project, mutation: Decidim::Budgets::CreateProjectType, description: "Creates a project"
      field :delete_project, mutation: Decidim::Budgets::DeleteProjectType, description: "Deletes a project"
      field :update_project, mutation: Decidim::Budgets::UpdateProjectType, description: "Updates a project"
    end
  end
end
