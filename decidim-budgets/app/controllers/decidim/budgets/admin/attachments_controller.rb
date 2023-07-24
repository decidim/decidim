# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # Controller that allows managing all the attachments for a participatory
      # process.
      #
      class AttachmentsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachments

        def after_destroy_path
          budget_projects_path(project.budget)
        end

        def attached_to
          project
        end

        def projects
          @projects ||= Decidim::Budgets::Project
            .joins("INNER JOIN decidim_budgets_budgets budget ON budget.id = decidim_budgets_projects.decidim_budgets_budget_id")
            .where(budget: { component: current_component })
        end

        def project
          @project ||= projects.find(params[:project_id])
        end
      end
    end
  end
end
