# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class UpdateProjectsBudget < Decidim::Command
        include TranslatableAttributes

        # Public: Initializes the command.
        #
        # destin_budget - the destination budget for which the projects should update to.
        # project_ids - the project ids to update.
        def initialize(destin_budget_id, project_ids)
          @destin_budget = find_budget(destin_budget_id)
          @project_ids = project_ids
          @response = { selection_name: "", successful: [], errored: [], failed_ids: [] }
        end

        def call
          return broadcast(:invalid_project_ids) if @project_ids.blank?
          return broadcast(:invalid_project_ids) if @destin_budget.blank?

          update_projects_budget

          broadcast(:update_projects_budget, @response)
        end

        private

        attr_reader :selection, :project_ids

        def update_projects_budget
          ::Decidim::Budgets::Project.where(id: project_ids).find_each do |project|
            if update_not_allowed?(project)
              @response[:errored] << translated_attribute(project.title)
              @response[:failed_ids] << project.id
            else
              transaction do
                update_project_budget project
              end
              @response[:successful] << translated_attribute(project.title)
            end
          end
        end

        def update_project_budget(project)
          project.update!(
            decidim_budgets_budget_id: @destin_budget.id
          )
        end

        def update_not_allowed?(project)
          origin_budget = project.budget
          return false unless origin_budget == @destin_budget

          origin_budget.component == @destin_budget.component
        end

        def find_budget(id)
          Budget.find(id)
        end
      end
    end
  end
end
