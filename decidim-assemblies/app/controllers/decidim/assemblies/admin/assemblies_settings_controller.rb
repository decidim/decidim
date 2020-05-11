# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller used to manage the assemblies settings for the current
      # organization.
      class AssembliesSettingsController < Decidim::Assemblies::Admin::ApplicationController
        layout "decidim/admin/assemblies"

        # GET /admin/assemblies_settings/edit
        def edit
          enforce_permission_to :edit, :assemblies_setting, assemblies_settings: current_assemblies_settings
          @form = assemblies_settings_form.from_model(current_assemblies_settings)
        end

        # PUT /admin/assemblies_settings/:id
        def update
          enforce_permission_to :update, :assemblies_setting, assemblies_settings: current_assemblies_settings

          @form = assemblies_settings_form
                  .from_params(params, assemblies_settings: current_assemblies_settings)

          UpdateAssembliesSetting.call(current_assemblies_settings, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("assemblies_settings.update.success", scope: "decidim.admin")
              redirect_to edit_assemblies_settings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("assemblies_settings.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        private

        def current_assemblies_settings
          @current_assemblies_settings ||= Decidim::AssembliesSetting.find_or_create_by!(decidim_organization_id: current_organization.id)
        end

        def assemblies_settings_form
          form(Decidim::Assemblies::Admin::AssembliesSettingForm)
        end
      end
    end
  end
end
