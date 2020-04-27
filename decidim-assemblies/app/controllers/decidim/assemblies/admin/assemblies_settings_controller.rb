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
          enforce_permission_to :edit, :assembly_setting, assembly_setting: current_assembly_setting
          @form = assembly_setting_form
                  .from_model(current_assembly_setting,
                              assembly_type: current_assembly_setting)
        end

        def index
        end

        # PUT /admin/assemblies_settings/:id
        def update
          enforce_permission_to :update, :assembly_setting, assembly_setting: current_assembly_setting

          @form = assembly_setting_form
                  .from_params(params, assembly_type: current_assembly_setting)

          UpdateAssembliesSetting.call(current_assembly_setting, @form) do
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

        # private

        # def available_assemblies_settings
        #   @available_assemblies_settings ||= AssembliesSetting.where(organization: current_organization)
        # end

        def current_assembly_setting
          @current_assembly_setting ||= AssembliesSetting.find(params[:id])
        end

        def assembly_setting_form
          form(Decidim::Assemblies::Admin::AssembliesSettingForm)
        end
      end
    end
  end
end
