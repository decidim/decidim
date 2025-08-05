# frozen_string_literal: true

module Decidim
  module Budgets
    class CreateProjectType < Decidim::Api::Types::BaseMutation
      graphql_name "CreateProject"

      description "Creates a Project"
      type Decidim::Budgets::ProjectType

      argument :attributes, ProjectAttributes, description: "input attributes to create a project", required: true

      def resolve(attributes:)
        form = Admin::ProjectForm.from_params(attributes.to_h)
                                 .with_context(
                                   current_component: object.component,
                                   current_organization: object.organization,
                                   current_user: context[:current_user],
                                   budget: object
                                 )

        Admin::CreateProject.call(form) do
          on(:ok, resource) do
            return resource
          end

          on(:invalid) do
            return GraphQL::ExecutionError.new(
              form.errors.full_messages.join(", ")
            )
          end
        end
      end

      def authorized?(attributes:)
        super && allowed_to?(:create, :project, object, context, scope: :admin)
      end
    end
  end
end
