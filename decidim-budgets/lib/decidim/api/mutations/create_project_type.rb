# frozen_string_literal: true

module Decidim
  module Budgets
    class CreateProjectType < Decidim::Api::Types::BaseMutation
      graphql_name "CreateProject"

      description "Creates a Project"
      type Decidim::Budgets::ProjectType

      argument :attributes, ProjectAttributes, description: "input attributes to create a project", required: true

      def resolve(attributes:)
        form = form(Admin::ProjectForm).from_params(attributes.to_h, budget: object)

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
        unless super && allowed_to?(:create, :project, object, { current_user: }, scope: :admin)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def self.permission_chain(object)
        super.unshift(Decidim::Budgets::Admin::Permissions)
      end
    end
  end
end
