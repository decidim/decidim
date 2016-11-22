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
        @component_manifest = Decidim.components.find do |manifest|
          manifest.name == params[:type].to_sym
        end

        authorize! :create, Component

        component_name = I18n.available_locales.each_with_object({}) do |locale, result|
          I18n.with_locale(locale) do
            result[locale] = I18n.t("components.#{@component_manifest.name}.name")
          end

          result
        end

        component = Component.new(
          name: component_name,
          participatory_process: participatory_process,
          component_type: @component_manifest.name
        )

        @form = ComponentForm.from_model(component)
      end

      def create
        authorize! :create, Component
        @form = ComponentForm.from_params(params)

        CreateComponent.call(@form, participatory_process) do
          on(:ok) do
            flash[:notice] = I18n.t("components.create.success", scope: "decidim.admin")
            redirect_to action: :index
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
            redirect_to action: :index
          end

          on(:error) do
            flash.now[:alert] = I18n.t("components.destroy.error", scope: "decidim.admin")
            redirect_to action: :index
          end
        end
      end
    end
  end
end
