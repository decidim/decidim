# frozen_string_literal: true

module Decidim
  # The controller to handle the user's notifications settings page.
  class NotificationsSettingsController < Decidim::ApplicationController
    include Decidim::UserProfile

    def show
      authorize! :show, current_user
      @notifications_settings = form(NotificationsSettingsForm).from_model(current_user)
    end

    def unsubscribe
      authorize! :update, current_user
      @unsubscribe_notifications_settings = false
      @notifications_settings = form(NotificationsSettingsForm).from_params(params)

      email_user = SignedGlobalID.find(params[:u], for: :unsubscribe_user)
      if email_user == current_user && current_user.newsletter_notifications
        UnsubscribeNotificationsSettings.call(current_user, @unsubscribe_notifications_settings) do
          on(:ok) do
            flash.now[:notice] = t("notifications_settings.update.success", scope: "decidim")
          end

          on(:invalid) do
            flash.now[:alert] = t("notifications_settings.update.error", scope: "decidim")
            render action: :show
          end
        end
      else
        redirect_to decidim.notifications_settings_path
      end
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
