# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to import results from a csv file for the Accountability component
      class ImportResultsController < Admin::ApplicationController
        def new
          enforce_permission_to :create, :result

          @form = form(Admin::ImportResultsForm).instance
        end

        def create
          enforce_permission_to :create, :result

          @form = form(Admin::ImportResultsForm).from_params(params, current_component:)

          if @form.valid?
            Decidim::Accountability::Admin::ImportResultsCsvJob.perform_later(current_user, current_component, @form.local_file_path)

            flash[:notice] = I18n.t("imports.create.success", scope: "decidim.accountability.admin")
            redirect_to import_results_path(current_participatory_space, current_component)
          else
            flash[:alert] = I18n.t("imports.create.invalid", scope: "decidim.accountability.admin")
            render action: "new", status: :unprocessable_content
          end
        end
      end
    end
  end
end
