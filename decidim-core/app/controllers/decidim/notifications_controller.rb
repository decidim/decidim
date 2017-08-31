# frozen_string_literal: true

module Decidim
  # The controller to handle the user's notifications dashboard.
  class NotificationsController < Decidim::ApplicationController
    helper Decidim::IconHelper
    helper Decidim::PaginateHelper
    include Paginable

    helper_method :notifications

    def index
      authorize! :read, Notification
      @notifications = paginate(notifications)
    end

    def destroy
      notification = notifications.find(params[:id])
      authorize! :destroy, notification
      notification.destroy
    end

    def read_all
      authorize! :destroy, notifications.first
      notifications.destroy_all
    end

    private

    def notifications
      @notifications ||= current_user.notifications.order(created_at: :desc)
    end

    # Private: overwrites the amount of elements per page.
    def per_page
      50
    end
  end
end
