# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetMutationType < Decidim::Api::Types::BaseObject
      description "Budget mutation"
      graphql_name "BudgetMutation"

      field :create_project, mutation: Decidim::Budgets::CreateProjectType, description: "create a project"
      field :delete_project, mutation: Decidim::Budgets::DeleteProjectType, description: "delete a project"
      field :project, type: Decidim::Budgets::ProjectMutationType, description: "A project mutation" do
        argument :id, GraphQL::Types::ID, description: "id of the project", required: true
      end
      field :update_project, mutation: Decidim::Budgets::UpdateProjectType, description: "update a project"

      def project(**args)
        Project.find_by(id: args[:id], budget: object)
      end
    end
  end
end
