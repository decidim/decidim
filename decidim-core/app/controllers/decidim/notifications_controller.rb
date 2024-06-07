# frozen_string_literal: true

module Decidim
  # The controller to handle the user's notifications deletion.
  class NotificationsController < Decidim::ApplicationController
    include HasSpecificBreadcrumb

    def index
      enforce_permission_to :read, :notification
    end

    def update
      notification = notifications.find(params[:id])
      enforce_permission_to(:update, :notification, notification:)
      if flash.notice.present?
        notification.extra["action"] = {
          "data" => flash.notice,
          "type" => "callout",
          "class" => "success"
        }
        notification.save
      end
      flash.discard
      if flash.alert.present?
        render html: ActionController::Base.helpers.content_tag(:div, flash.alert, class: "callout alert"), layout: false
      else
        render html: ActionController::Base.helpers.content_tag(:div, flash.notice, class: "callout success"), layout: false
      end
    end

    def destroy
      notification = notifications.find(params[:id])
      enforce_permission_to(:destroy, :notification, notification:)
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

    def breadcrumb_item
      {
        label: t("layouts.decidim.user_menu.notifications"),
        active: true,
        url: notifications_path
      }
    end
  end
end
