# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class UpdateProjectsBudget < Decidim::Command
        include TranslatableAttributes

        # Public: Initializes the command.
        #
        # destination_budget - the destination budget for which the projects should update to.
        # project_ids - the project ids to update.
        def initialize(destination_budget, project_ids)
          @destination_budget = destination_budget
          @project_ids = project_ids
          @response = { selection_name: "", successful: [], errored: [], failed_ids: [] }
        end

        def call
          return broadcast(:invalid_project_ids) if @project_ids.blank?
          return broadcast(:invalid_project_ids) if @destination_budget.blank?

          update_projects_budget

          broadcast(:update_projects_budget, @response)
        end

        private

        attr_reader :selection, :project_ids

        def update_projects_budget
          ::Decidim::Budgets::Project.includes(:budget, budget: { component: :participatory_space }).where(id: project_ids).find_each do |project|
            if update_allowed?(project)
              transaction do
                project.update!(
                  decidim_budgets_budget_id: @destination_budget.id
                )
              end
              @response[:successful] << translated_attribute(project.title)
            else
              @response[:errored] << translated_attribute(project.title)
              @response[:failed_ids] << project.id
            end
          end
        end

        def update_allowed?(project)
          origin_budget = project.budget
          return false if origin_budget == @destination_budget

          origin_budget.participatory_space == @destination_budget.participatory_space
        end
      end
    end
  end
end
