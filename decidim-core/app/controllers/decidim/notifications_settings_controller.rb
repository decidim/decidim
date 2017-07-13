# frozen_string_literal: true

module Decidim
  # The controller to handle the user's notifications settings page.
  class NotificationsSettingsController < Decidim::ApplicationController
    include Decidim::UserProfile

    def show
      authorize! :show, current_user
      @notifications_settings = form(NotificationsSettingsForm).from_model(current_user)
    end

    def update
      authorize! :update, current_user
      @notifications_settings = form(NotificationsSettingsForm).from_params(params)

      UpdateNotificationsSettings.call(current_user, @notifications_settings) do
        on(:ok) do
          flash.now[:notice] = t("notifications_settings.update.success", scope: "decidim")
        end

        on(:invalid) do
          flash.now[:alert] = t("notifications_settings.update.error", scope: "decidim")
        end
      end

      render action: :show
    end
  end
end
