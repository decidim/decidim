# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class ProposalsImportsController < Admin::ApplicationController
        def new
          enforce_permission_to :import_proposals, :projects

          @form = form(Admin::ProjectImportProposalsForm).instance
        end

        def create
          enforce_permission_to :import_proposals, :projects

          @form = form(Admin::ProjectImportProposalsForm).from_params(params)
          Admin::ImportProposalsToBudgets.call(@form) do
            on(:ok) do |projects|
              flash[:notice] = I18n.t("proposals_imports.create.success", scope: "decidim.budgets.admin", number: projects.length)
              redirect_to EngineRouter.admin_proxy(current_component).root_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("proposals_imports.create.invalid", scope: "decidim.budgets.admin")
              render action: "new"
            end
          end
        end
      end
    end
  end
end
