# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to import resources from a file.
    class ImportsController < Decidim::Admin::ApplicationController
      include Decidim::ComponentPathHelper

      helper_method :import_manifest

      def new
        enforce_permission_to :import, :component_data, component: current_component
        raise ActionController::RoutingError, "Not Found" unless import_manifest

        @form = form(import_manifest.form_class).from_params(
          { name: import_manifest.name },
          current_component:
        )
      end

      def create
        enforce_permission_to :import, :component_data, component: current_component
        raise ActionController::RoutingError, "Not Found" unless import_manifest

        @form = form(import_manifest.form_class).from_params(
          params,
          current_component:,
          current_organization:
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

      def example
        enforce_permission_to :import, :component_data, component: current_component
        raise ActionController::RoutingError, "Not Found" unless import_manifest

        @form = form(Decidim::Admin::ImportExampleForm).from_params(params).with_context(
          current_component:,
          current_organization:
        )

        respond_to do |format|
          @form.available_formats.each do |key, mime|
            format.public_send(key) do
              CreateImportExample.call(@form) do
                on(:ok) do |data|
                  filename = "#{current_component.manifest_name}-#{import_manifest.name}-example.#{key}"
                  send_data data.read, disposition: :attachment, filename:, type: mime
                end

                on(:invalid) do
                  flash[:alert] = t("decidim.admin.imports.example_error")
                  redirect_to admin_imports_path(current_component, name: import_name)
                end
              end
            end
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
        params[:name]
      end

      def current_component
        @current_component ||= current_participatory_space.components.find(params[:component_id])
      end
    end
  end
end
