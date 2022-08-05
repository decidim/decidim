# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to import results from a csv file for the Accountability component
      class ProjectsImportController < Admin::ApplicationController
        def new
          enforce_permission_to :create, :import_projects
          @form = form(Admin::ResultImportProjectsForm).instance
        end

        def create
          enforce_permission_to :create, :import_projects
          @form = form(Admin::ResultImportProjectsForm).from_params(params, accountability_component: current_component)
          Admin::ImportProjectsToAccountability.call(@form) do
            on(:ok) do |projects|
              flash[:notice] = I18n.t("decidim.accountability.admin.projects_import.new.success", count: projects)
              redirect_to results_path
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
