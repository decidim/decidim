# frozen_string_literal: true

module Decidim
  # The controller to handle the user's notifications dashboard.
  class NotificationsController < Decidim::ApplicationController
    helper Decidim::IconHelper

    helper_method :collection, :read_notifications, :unread_notifications

    def index
      authorize! :read, Notification
    end

    def read
      authorize! :update, Notification
      notification = collection.find(params[:id])
      notification.update_attributes(read_at: Time.current)
    end

    private

    def collection
      @collection ||= current_user.notifications.order(created_at: :desc)
    end

    def unread_notifications
      @unread_notifications ||= collection.unread
    end

    def read_notifications
      @read_notifications ||= collection.read
    end
  end
end
