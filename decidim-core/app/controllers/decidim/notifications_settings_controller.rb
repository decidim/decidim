# frozen_string_literal: true

module Decidim
  # The controller to handle the user's notifications settings page.
  class NotificationsSettingsController < Decidim::ApplicationController
    include Decidim::UserProfile

    def show
      enforce_permission_to :read, :user, current_user: current_user
      @notifications_settings = form(NotificationsSettingsForm).from_model(current_user)
    end

    def update
      enforce_permission_to :update, :user, current_user: current_user
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
