# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class ProposalsImportsController < Admin::ApplicationController
        helper_method :budget

        def new
          enforce_permission_to :import_proposals, :projects

          @form = form(Admin::ProjectImportProposalsForm).instance
        end

        def create
          enforce_permission_to :import_proposals, :projects

          @form = form(Admin::ProjectImportProposalsForm).from_params(params, budget:)
          Admin::ImportProposalsToBudgets.call(@form) do
            on(:ok) do |projects|
              flash[:notice] = I18n.t("proposals_imports.create.success", scope: "decidim.budgets.admin", number: projects.length)
              redirect_to budget_projects_path(budget)
            end

            on(:invalid) do
              flash[:alert] = I18n.t("proposals_imports.create.invalid", scope: "decidim.budgets.admin")
              render action: "new"
            end
          end
        end

        private

        def budget
          @budget ||= Budget.where(component: current_component).find_by(id: params[:budget_id])
        end
      end
    end
  end
end
