# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing the Components for a Feature.
    #
    class ComponentsController < ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      helper_method :manifest

      def new
        authorize! :create, Component
        @form = form(ComponentForm).instance(name: default_name(manifest))
      end

      def create
        authorize! :create, Component
        @form = form(ComponentForm).from_params(params)

        CreateComponent.call(manifest, @form, feature) do
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
            redirect_to action: :index, controller: :features
          end
        end
      end

      private

      def manifest
        @manifest = Decidim.find_component_manifest(params[:type])
      end

      def feature
        @feature ||= participatory_process.features.find(params[:feature_id])
      end

      def default_name(manifest)
        TranslationsHelper.multi_translation(
          "components.#{manifest.name}.name",
          current_organization.available_locales
        )
      end
    end
  end
end
