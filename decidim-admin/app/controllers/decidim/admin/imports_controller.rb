# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to import resources from a file.
    class ImportsController < Decidim::Admin::ApplicationController
      include Decidim::ComponentPathHelper

      def new
        enforce_permission_to :import, :component_data, component: component
        @import = Admin::ImportForm.new(component: component)
      end

      def create
        enforce_permission_to :import, :component_data, component: component

        @import = form(Admin::ImportForm).from_params(
          params,
          current_component: component,
          current_organization: current_organization
        )

        CreateImport.call(@import) do
          on(:ok) do
            flash[:notice] = t("decidim.admin.imports.notice", count: @imported_data.count)
            redirect_to manage_component_path(component)
          end

          on(:invalid) do
            flash[:alert] = t("decidim.admin.imports.error")
            render action: "new"
          end
        end
      end

      private

      def default_format
        "json"
      end

      def component
        @component ||= current_participatory_space.components.find(params[:component_id])
      end
    end
  end
end
