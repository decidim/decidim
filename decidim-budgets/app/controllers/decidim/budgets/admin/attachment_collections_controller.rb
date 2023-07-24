# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # Controller that allows managing all the attachment collections for a budget.
      #
      class AttachmentCollectionsController < Admin::ApplicationController
        include Decidim::Admin::Concerns::HasAttachmentCollections

        def after_destroy_path
          project_attachment_collections_path(project, project.component, current_participatory_space)
        end

        def collection_for
          project
        end

        def project
          @project ||= Decidim::Budgets::Project
                       .joins("INNER JOIN decidim_budgets_budgets budget ON budget.id = decidim_budgets_projects.decidim_budgets_budget_id")
                       .where(budget: { component: current_component }).find(params[:project_id])
        end
      end
    end
  end
end
