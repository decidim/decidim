# frozen_string_literal: true

module Decidim
  # The controller to handle the user's notifications deletion.
  class NotificationsController < Decidim::ApplicationController
    def destroy
      notification = notifications.find(params[:id])
      enforce_permission_to :destroy, :notification, notification: notification
      notification.destroy
    end

    def read_all
      enforce_permission_to :destroy, :notification, notification: notifications.first
      notifications.destroy_all
    end

    private

    def notifications
      @notifications ||= current_user.notifications.order(created_at: :desc)
    end
  end
end
