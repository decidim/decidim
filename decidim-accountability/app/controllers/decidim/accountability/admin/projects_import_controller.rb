# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to import results from a csv file for the Accountability component
      class ProjectsImportController < Admin::ApplicationController
        def new
          # enforce_permission_to import_projects, :results
          # @budget_component_id = budget_component_id
          @form = form(Admin::ResultImportProjectsForm).instance
        end

        def create
          @form = form(Admin::ResultImportProjectsForm).from_params(params, accountability_component: current_component)
          Admin::ImportProjectsToAccountability.call(@form) do
            on(:ok) do |projects|
              flash[:notice] = I18n.t("projects_import.new.success", scope: "decidim.accountability.admin", number: projects.length)
              redirect_to results_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("proposals_imports.create.invalid", scope: "decidim.budgets.admin")
              render action: "new"
            end
          end
        end

        # private

        # def accountability_component
        #   Decidim::Component.find_by(id: current_component, manifest_name: "accountability")
        # end
      end
    end
  end
end
