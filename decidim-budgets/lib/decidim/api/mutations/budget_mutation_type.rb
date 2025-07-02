# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetMutationType < Decidim::Api::Types::BaseObject
      description "Budget mutation"
      graphql_name "Budget"

      field :create_project, mutation: Decidim::Budgets::CreateProjectType, description: "create a project"
      field :delete_project, mutation: Decidim::Budgets::DeleteProjectType, description: "delete a project"
      field :update_project, mutation: Decidim::Budgets::UpdateProjectType, description: "update a project"
    end
  end
end
