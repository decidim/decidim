# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetMutationType < Decidim::Api::Types::BaseObject
      description "Budget mutation"
      graphql_name "BudgetMutation"

      field :delete, mutation: Decidim::Budgets::DeleteBudgetType, description: "Deletes a budget"
      field :update, mutation: Decidim::Budgets::UpdateBudgetType, description: "Updates a budget"

      field :create_project, mutation: Decidim::Budgets::CreateProjectType, description: "Creates a project"
      field :project, type: Decidim::Budgets::ProjectMutationType, description: "A project mutation" do
        argument :id, GraphQL::Types::ID, description: "id of the project", required: true
      end

      def project(**args)
        Project.find_by(id: args[:id], budget: object)
      end
    end
  end
end
