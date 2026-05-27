# frozen_string_literal: true

module Decidim
  module Budgets
    class DeleteProjectType < Api::SoftDeleteResourceType
      description "Deletes a project"

      type Decidim::Budgets::ProjectType

      required_scopes "api:read", "admin:read", "admin:write"

      def authorized?(id:)
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
        object.projects.find(id)
      end

      def trashable_deleted_resource_type
        :project
      end
    end
  end
end
