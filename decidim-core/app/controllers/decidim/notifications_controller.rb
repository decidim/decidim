# frozen_string_literal: true

module Decidim
  # The controller to handle the user's notifications dashboard.
  class NotificationsController < Decidim::ApplicationController
    helper Decidim::IconHelper

    helper_method :notifications

    def index
      authorize! :read, Notification
    end

    def destroy
      notification = notifications.find(params[:id])
      authorize! :destroy, notification
      notification.destroy
    end

    private

    def notifications
      @notifications ||= current_user.notifications.order(created_at: :desc)
    end
  end
end
