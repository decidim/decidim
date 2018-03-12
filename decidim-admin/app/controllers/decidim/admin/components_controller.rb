# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the Participatory Process' Components in the
    # admin panel.
    #
    class ComponentsController < Decidim::Admin::ApplicationController
      helper_method :manifest, :current_participatory_space

      def index
        authorize! :read, Component
        @manifests = Decidim.component_manifests
        @components = current_participatory_space.components
      end

      def new
        authorize! :create, Component

        @component = Component.new(
          name: default_name(manifest),
          manifest_name: params[:type],
          participatory_space: current_participatory_space
        )

        @form = form(ComponentForm).from_model(@component)
      end

      def create
        @form = form(ComponentForm).from_params(params)
        authorize! :create, Component

        CreateComponent.call(manifest, @form, current_participatory_space) do
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

      def edit
        @component = query_scope.find(params[:id])
        authorize! :update, @component

        @form = form(ComponentForm).from_model(@component)
      end

      def update
        @component = query_scope.find(params[:id])
        @form = form(ComponentForm).from_params(params)
        authorize! :update, @component

        UpdateComponent.call(@form, @component) do
          on(:ok) do |settings_changed, previous_settings, current_settings|
            handle_component_settings_change(previous_settings, current_settings) if settings_changed

            flash[:notice] = I18n.t("components.update.success", scope: "decidim.admin")
            redirect_to action: :index
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("components.update.error", scope: "decidim.admin")
            render action: "new"
          end
        end
      end

      def destroy
        @component = query_scope.find(params[:id])
        authorize! :destroy, @component

        DestroyComponent.call(@component, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("components.destroy.success", scope: "decidim.admin")
            redirect_to action: :index
          end

          on(:invalid) do
            flash[:alert] = I18n.t("components.destroy.error", scope: "decidim.admin")
            redirect_to action: :index
          end
        end
      end

      def publish
        @component = query_scope.find(params[:id])
        authorize! :update, @component

        PublishComponent.call(@component, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("components.publish.success", scope: "decidim.admin")
            redirect_to action: :index
          end
        end
      end

      def unpublish
        @component = query_scope.find(params[:id])
        authorize! :update, @component

        UnpublishComponent.call(@component, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("components.unpublish.success", scope: "decidim.admin")
            redirect_to action: :index
          end
        end
      end

      private

      def query_scope
        current_participatory_space.components
      end

      def manifest
        Decidim.find_component_manifest(params[:type])
      end

      def default_name(manifest)
        TranslationsHelper.multi_translation(
          "decidim.components.#{manifest.name}.name",
          current_organization.available_locales
        )
      end

      def handle_component_settings_change(previous_settings, current_settings)
        return if @component.participatory_space.allows_steps?

        Decidim::SettingsChange.publish(
          @component,
          previous_settings["default_step"] || {},
          current_settings["default_step"] || {}
        )
      end
    end
  end
end
