# frozen_string_literal: true

module Decidim
  module Apiext
    module Budgets
      class BudgetMutationType < Decidim::Api::Types::BaseObject
        include ::Decidim::Apiext::ApiPermissions
        include ::Decidim::Apiext::ApiMutationHelpers

        graphql_name "BudgetMutation"
        description "A Budget of budget component"

        field :id, GraphQL::Types::ID, "Budget's unique ID", null: false

        field :create_project, ::Decidim::Budgets::ProjectType, null: false do
          description "A mutation to create a project within a budget."

          argument :attributes, ProjectAttributes, "project attributes", required: true
        end

        field :update_project, ::Decidim::Budgets::ProjectType, null: true do
          description "A mutation to update a project within a budget."

          argument :attributes, ProjectAttributes, "project attributes", required: true
          argument :id, GraphQL::Types::ID, "ID of a project", required: true
        end

        field :project, ProjectMutationType, description: "Mutates a project", null: true do
          argument :id, GraphQL::Types::ID, "ID of a project", required: true
        end

        field :delete_project, ::Decidim::Budgets::ProjectType, null: true do
          description "A mutation to delete a project within a budget."

          argument :id, GraphQL::Types::ID, "ID of a project", required: true
        end

        def create_project(attributes:)
          enforce_permission_to :create, :project

          form = project_form_from(attributes)

          ::Decidim::Budgets::Admin::CreateProject.call(form) do
            on(:ok) do
              # The command does not broadcast the project so we need to fetch it
              # from a private method within the command itself.
              return project
            end
            on(:invalid) do
              return GraphQL::ExecutionError.new(
                form.errors.full_messages.join(", ")
              )
            end
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.budgets.admin.projects.create.invalid")
          )
        end

        def update_project(id:, attributes:)
          project = object.projects.find_by(id: id)
          return unless project

          enforce_permission_to :update, :project, project: project

          form = project_form_from(attributes)
          ::Decidim::Budgets::Admin::UpdateProject.call(form, project) do
            on(:ok) do
              return project
            end
            on(:invalid) do
              return GraphQL::ExecutionError.new(
                form.errors.full_messages.join(", ")
              )
            end
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.budgets.admin.projects.update.invalid")
          )
        end

        def delete_project(id:)
          project = object.projects.find_by(id: id)
          return unless project

          enforce_permission_to :destroy, :project, project: project

          Decidim::Budgets::Admin::DestroyProject.call(project, current_user) do
            on(:ok) do
              return project
            end
          end

          GraphQL::ExecutionError.new(
            I18n.t("decidim.budgets.admin.projects.destroy.invalid")
          )
        end

        def project(id:)
          object.projects.find(id)
        rescue ActiveRecord::RecordNotFound
          GraphQL::ExecutionError.new(
            I18n.t("decidim.apiext.budgets.project_mutation.invalid")
          )
        end

        private

        def project_form_from(attributes, project = nil)
          ::Decidim::Budgets::Admin::ProjectForm.from_params(
            "project" => project_params(attributes, project)
          ).with_context(
            current_organization: current_organization,
            current_component: object.component,
            current_user: current_user,
            budget: object
          )
        end

        def project_params(attributes, project = nil)
          {
            "title" => json_value(attributes.title),
            "description" => json_value(attributes.description),
            "budget_amount" => attributes.budget_amount,
            "budget_amount_min" => attributes.budget_amount_min,
            "address" => attributes&.location&.address,
            "latitude" => attributes&.location&.latitude,
            "longitude" => attributes&.location&.longitude,
            "decidim_category_id" => attributes.category_id,
            "decidim_scope_id" => attributes.scope_id,
            "proposal_ids" => attributes.proposal_ids || related_ids_for(project, :proposals),
            "idea_ids" => attributes.idea_ids || related_ids_for(project, :ideas),
            "plan_ids" => attributes.plan_ids || related_ids_for(project, :plans)
          }.tap do |attrs|
            attrs.merge!(attributes.main_image_attributes) if attributes.main_image_attributes
          end
        end

        def related_ids_for(project, resource)
          return [] unless project

          project.linked_resources(resource, "included_#{resource}").map(&:id)
        end

        def current_organization
          context[:current_organization]
        end
      end
    end
  end
end
