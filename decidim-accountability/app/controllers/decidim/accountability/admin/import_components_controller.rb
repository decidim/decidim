# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to import results from a component
      class ImportComponentsController < Admin::ApplicationController
        def new
          enforce_permission_to :create, :import_component
          @form = form(Admin::ImportComponentForm).from_params(params, accountability_component: current_component)
        end

        def create
          enforce_permission_to :create, :import_component
          @form = form(Admin::ImportComponentForm).from_params(params, accountability_component: current_component)

          ImportComponentToAccountability.call(@form) do
            on(:ok) do |projects|
              flash[:notice] = I18n.t("import_components.new.success", scope: "decidim.accountability.admin", count: projects)
              redirect_to results_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("import_components.create.invalid", scope: "decidim.accountability.admin")
              render action: "new"
            end
          end
        end

        def results_import_params
          params[:results_import] || {}
        end
      end
    end
  end
end
