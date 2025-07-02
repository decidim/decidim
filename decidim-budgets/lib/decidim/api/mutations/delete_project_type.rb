# frozen_string_literal: true

module Decidim
  module Budgets
    class DeleteProjectType < Api::SoftDeleteResourceType
      description "deletes a project"

      type Decidim::Budgets::ProjectType

      def authorized?(id:)
        project = find_resource(id)
        context[:trashable_deleted_resource] = project

        super && allowed_to?(:soft_delete, :project, project, context, scope: :admin)
      end

      private

      def find_resource(id)
        object.projects.find_by(id:)
      end

      def trashable_deleted_resource_type
        :budget
      end
    end
  end
end
