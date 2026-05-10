# frozen_string_literal: true

module Decidim
  # The controller to handle the subscriptions to push notifications
  class NotificationsSubscriptionsController < Decidim::ApplicationController
    rescue_from Decidim::NotificationsSubscriptionsPersistor::UnsupportedPushSubscriptionEndpointError, with: :unsupported_browser

    def create
      Decidim::NotificationsSubscriptionsPersistor.new(current_user).add_subscription(params)
      head :ok
    end

    def destroy
      Decidim::NotificationsSubscriptionsPersistor.new(current_user).delete_subscription(params[:auth])
      head :ok
    end

    private

    def unsupported_browser
      render json: { error: I18n.t("notifications_settings.show.push_notifications_unsupported_browser", scope: "decidim") }, status: :unprocessable_content
    end
  end
end
