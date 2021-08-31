# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to import resources from a file.
    class ImportsController < Decidim::Admin::ApplicationController
      include Decidim::ComponentPathHelper
      helper UserGroupHelper

      def new
        enforce_permission_to :import, :component_data, component: current_component
        @form = form(Admin::ImportForm).from_params(
          {
            # We need to set "default" creator because form-class doesn't have context / current_component
            # when it sets it's default values.
            creator: current_component.manifest.import_manifests.first.creator,
            creator_param: params["creator"]
          },
          current_component: current_component
        )
      end

      def create
        enforce_permission_to :import, :component_data, component: current_component

        @form = form(Admin::ImportForm).from_params(
          params,
          current_component: current_component,
          current_organization: current_organization
        )

        notification_resource = @form&.notification_resource || "resource"

        CreateImport.call(@form) do
          on(:ok) do |imported_data|
            flash[:notice] = t("decidim.admin.imports.notice",
                               number: imported_data.length,
                               resource_name: notification_resource)
            redirect_to manage_component_path(current_component)
          end

          on(:invalid) do
            flash.now[:alert] = t("decidim.admin.imports.error")
            render :new
          end
        end
      end

      private

      def current_component
        @current_component ||= current_participatory_space.components.find(params[:component_id])
      end
    end
  end
end
