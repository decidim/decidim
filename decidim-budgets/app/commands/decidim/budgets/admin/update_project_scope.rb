# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class UpdateProjectScope < Decidim::Command
        include TranslatableAttributes

        # Public: Initializes the command.
        #
        # scope_id - the scope id to update
        # project_ids - the project ids to update.
        def initialize(scope_id, project_ids)
          @scope = ::Decidim::Scope.find_by id: scope_id
          @project_ids = project_ids
          @response = { scope_name: "", successful: [], errored: [] }
        end

        def call
          return broadcast(:invalid_scope) if @scope.blank?
          return broadcast(:invalid_project_ids) if @project_ids.blank?

          update_projects_scope

          broadcast(:update_projects_scope, @response)
        end

        private

        attr_reader :scope, :project_ids

        def update_projects_scope
          @response[:scope_name] = translated_attribute(scope.name, scope.organization)
          ::Decidim::Budgets::Project.where(id: project_ids).find_each do |project|
            if scope == project.scope
              @response[:errored] << translated_attribute(project.title)
            else
              transaction do
                update_project_scope project
              end
              @response[:successful] << translated_attribute(project.title)
            end
          end
        end

        def update_project_scope(project)
          project.update!(
            scope: scope
          )
        end
      end
    end
  end
end
