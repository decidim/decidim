# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to import resources from a file.
    class ImportsController < Decidim::Admin::ApplicationController
      include Decidim::ComponentPathHelper
      helper UserGroupHelper

      helper_method :import_manifest

      def new
        enforce_permission_to :import, :component_data, component: current_component
        raise ActionController::RoutingError, "Not Found" unless import_manifest

        @form = form(Admin::ImportForm).from_params(
          { name: import_manifest.name },
          current_component: current_component
        )
      end

      def create
        enforce_permission_to :import, :component_data, component: current_component
        raise ActionController::RoutingError, "Not Found" unless import_manifest

        @form = form(Admin::ImportForm).from_params(
          params,
          current_component: current_component,
          current_organization: current_organization
        )

        CreateImport.call(@form) do
          on(:ok) do |imported_data|
            flash[:notice] = t("decidim.admin.imports.notice",
                               count: imported_data.length,
                               resource_name: import_manifest.message(:resource_name, count: imported_data.length))
            redirect_to manage_component_path(current_component)
          end

          on(:invalid) do
            flash.now[:alert] = t("decidim.admin.imports.error")
            render :new
          end
        end
      end

      private

      def import_manifest
        @import_manifest ||= current_component.manifest.import_manifests.find do |import_manifest|
          import_manifest.name.to_s == import_name
        end
      end

      def import_name
        params[:name] || params.fetch(:import, {})[:name]
      end

      def current_component
        @current_component ||= current_participatory_space.components.find(params[:component_id])
      end
    end
  end
end
