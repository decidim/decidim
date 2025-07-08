# frozen_string_literal: true

module Decidim
  module Demographics
    module Admin
      class SettingsController < Decidim::Demographics::Admin::ApplicationController
        def show
          enforce_permission_to(:update, :demographics)

          @form = form(Admin::DemographicsSettingsForm).from_model(demographic)
        end

        def update
          enforce_permission_to(:update, :demographics)

          @form = form(Admin::DemographicsSettingsForm).from_params(params)

          Admin::UpdateDemographicsSettings.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("update.success", scope: "decidim.demographics.admin.settings")
              redirect_to decidim_admin_demographics.settings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("update.invalid", scope: "decidim.demographics.admin.settings")
              render action: "edit"
            end
          end
        end
      end
    end
  end
end
