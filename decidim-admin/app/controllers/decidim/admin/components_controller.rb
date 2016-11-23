# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class ComponentsController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      def index
        authorize! :read, Component
        @component_manifests = Decidim.components
        @components = participatory_process.components
      end

      def new
        @component_manifest = find_manifest(params[:type])
        feature = participatory_process.features.find(params[:feature_id])

        authorize! :create, Component

        component = Component.new(
          name: default_component_name(@component_manifest),
          participatory_process: participatory_process,
          feature: feature,
          component_type: @component_manifest.name
        )

        @form = ComponentForm.from_model(component)
        @form.feature_id = feature.id
      end

      def create
        authorize! :create, Component

        @component_manifest = find_manifest(params.dig(:component, :component_type))
        @form = ComponentForm.from_params(params)

        CreateComponent.call(@form, participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("components.create.success", scope: "decidim.admin")
            redirect_to action: :index, controller: :features
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("components.create.error", scope: "decidim.admin")
            render action: "new"
          end
        end
      end

      def destroy
        @component = participatory_process.components.find(params[:id])
        authorize! :destroy, @component

        DestroyComponent.call(@component) do
          on(:ok) do
            flash[:notice] = I18n.t("components.destroy.success", scope: "decidim.admin")
            redirect_to action: :index, controller: :features
          end

          on(:error) do
            flash.now[:alert] = I18n.t("components.destroy.error", scope: "decidim.admin")
            redirect_to action: :index, component: :features
          end
        end
      end

      private

      def find_manifest(type)
        Decidim.components.find { manifest.name == type }
      end

      def default_component_name(manifest)
      end
    end
  end
end
