# frozen_string_literal: true

module Decidim
  module Budgets
    class DeleteProjectType < Api::SoftDeleteResourceType
      description "Deletes a project"

      type Decidim::Budgets::ProjectType

      required_scopes "api:read", "admin:read", "admin:write"

      # The id is resolved from the parent `project(id:)` field when the
      # mutation is nested, so it is only required when the mutation is
      # reached with a budget as parent object.
      argument :id, GraphQL::Types::ID, "The ID of the resource", required: false

      def authorized?(id: nil)
        project = find_resource(id)

        context[:project] = project
        context[:trashable_deleted_resource] = project

        unless super && allowed_to?(:soft_delete, :project, project, context)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def self.permission_chain(object)
        super.unshift(Decidim::Budgets::Admin::Permissions)
      end

      private

      def find_resource(id)
        return object if object.is_a?(Decidim::Budgets::Project)

        object.projects.find(id)
      end

      def trashable_deleted_resource_type
        :project
      end
    end
  end
end
