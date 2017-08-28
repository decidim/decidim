# frozen_string_literal: true

module Decidim
  # The controller to handle the user's notifications dashboard.
  class NotificationsController < Decidim::ApplicationController
    helper Decidim::IconHelper

    helper_method :collection, :read_notifications, :unread_notifications

    def index
      authorize! :read, Notification
    end

    private

    def collection
      @collection ||= current_user.notifications.order(created_at: :desc)
    end

    def unread_notifications
      @unread_notifications ||= collection.limit(3)
    end

    def read_notifications
      @read_notifications ||= collection.offset(3)
    end
  end
end
