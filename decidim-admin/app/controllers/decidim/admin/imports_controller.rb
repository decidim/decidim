# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to import resources from a file.
    class ImportsController < Decidim::Admin::ApplicationController
      include Decidim::ComponentPathHelper
      def new
        enforce_permission_to :import, :component_data, component: current_component
        @import = Admin::ImportForm.new(current_component: current_component)
      end

      def create
        enforce_permission_to :import, :component_data, component: current_component

        @import = form(Admin::ImportForm).from_params(
          params,
          current_component: current_component,
          current_organization: current_organization
        )

        CreateImport.call(@import) do
          on(:ok) do |imported_data|
            flash[:notice] = t("decidim.admin.imports.notice",
                               number: imported_data.length,
                               resource_name: imported_data.first.resource_manifest.name.pluralize)
            redirect_to manage_component_path(current_component)
          end

          on(:invalid) do
            flash[:alert] = t("decidim.admin.imports.error")
            redirect_back(fallback_location: manage_component_path(current_component))
          end
        end
      end

      private

      def default_format
        "json"
      end

      def current_component
        @current_component ||= current_participatory_space.components.find(params[:component_id])
      end
    end
  end
end
