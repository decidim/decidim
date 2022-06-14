# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # Controller used to manage the initiatives settings for the current
      # organization.
      class InitiativesSettingsController < Decidim::Initiatives::Admin::ApplicationController
        layout "decidim/admin/initiatives"

        # GET /admin/initiatives_settings/edit
        def edit
          enforce_permission_to :update, :initiatives_settings, initiatives_settings: current_initiatives_settings
          @form = initiatives_settings_form.from_model(current_initiatives_settings)
        end

        # PUT /admin/initiatives_settings
        def update
          enforce_permission_to :update, :initiatives_settings, initiatives_settings: current_initiatives_settings

          @form = initiatives_settings_form
                  .from_params(params, initiatives_settings: current_initiatives_settings)

          UpdateInitiativesSettings.call(current_initiatives_settings, @form) do
            on(:ok) do
              flash[:notice] = I18n.t("initiatives_settings.update.success", scope: "decidim.admin")
              redirect_to edit_initiatives_setting_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("initiatives_settings.update.error", scope: "decidim.admin")
              render :edit
            end
          end
        end

        private

        def current_initiatives_settings
          @current_initiatives_settings ||= Decidim::InitiativesSettings.find_or_create_by!(organization: current_organization)
        end

        def initiatives_settings_form
          form(Decidim::Initiatives::Admin::InitiativesSettingsForm)
        end
      end
    end
  end
end
