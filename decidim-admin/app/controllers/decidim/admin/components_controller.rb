# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the Participatory Process' Components in the
    # admin panel.
    #
    class ComponentsController < Decidim::Admin::ApplicationController
      helper_method :manifest, :current_participatory_space

      def index
        enforce_permission_to :read, :component
        @manifests = Decidim.component_manifests
        @components = current_participatory_space.components
      end

      def new
        enforce_permission_to :create, :component

        @component = Component.new(
          name: default_name(manifest),
          manifest_name: params[:type],
          participatory_space: current_participatory_space,
          settings: {
            scope_id: current_participatory_space.scope.try(:id)
          }
        )

        @form = form(@component.form_class).from_model(@component)
      end

      def create
        @form = form(manifest.component_form_class).from_params(component_params)
        enforce_permission_to :create, :component

        CreateComponent.call(@form) do
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
        enforce_permission_to :update, :component, component: @component

        @form = form(@component.form_class).from_model(@component)
      end

      def update
        @component = query_scope.find(params[:id])
        @form = form(@component.form_class).from_params(component_params)
        enforce_permission_to :update, :component, component: @component

        UpdateComponent.call(@form, @component, current_user) do
          on(:ok) do |settings_changed, previous_settings, current_settings|
            handle_component_settings_change(previous_settings, current_settings) if settings_changed

            flash[:notice] = I18n.t("components.update.success", scope: "decidim.admin")
            redirect_to action: :index
          end

          on(:invalid) do
            flash[:alert] = I18n.t("components.update.error", scope: "decidim.admin")
            render action: :edit
          end
        end
      end

      def destroy
        @component = query_scope.find(params[:id])
        enforce_permission_to :destroy, :component, component: @component

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
        enforce_permission_to :publish, :component, component: @component

        PublishComponent.call(@component, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("components.publish.success", scope: "decidim.admin")
            redirect_to action: :index
          end
        end
      end

      def unpublish
        @component = query_scope.find(params[:id])
        enforce_permission_to :unpublish, :component, component: @component

        UnpublishComponent.call(@component, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("components.unpublish.success", scope: "decidim.admin")
            redirect_to action: :index
          end
        end
      end

      def share
        @component = query_scope.find(params[:id])
        share_token = @component.share_tokens.create!(user: current_user, organization: current_organization)

        redirect_to share_token.url
      end

      private

      # Processes the component params so the form object defined in the manifest (component_form_class_name)
      # can assign and validate the attributes when using #from_params.
      def component_params
        new_settings = proc { |name, data| Component.build_settings(manifest, name, data, current_organization) }

        params[:component].permit!.tap do |hsh|
          hsh[:id] = params[:id]
          hsh[:manifest] = manifest
          hsh[:participatory_space] = current_participatory_space
          hsh[:settings] = new_settings.call(:global, hsh[:settings])
          if hsh[:default_step_settings]
            hsh[:default_step_settings] = new_settings.call(:step, hsh[:default_step_settings])
          else
            hsh[:step_settings] ||= {}
            hsh[:step_settings].each do |key, value|
              hsh[:step_settings][key] = new_settings.call(:step, value)
            end
          end
        end
      end

      def query_scope
        current_participatory_space.components
      end

      def manifest
        @component&.manifest || Decidim.find_component_manifest(params[:type])
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
