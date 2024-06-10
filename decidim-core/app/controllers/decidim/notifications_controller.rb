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
      notification.set_action!("callout", flash.notice, class: "success") if flash.notice.present?
      flash.discard
      klass = "success"
      text = flash.notice
      if flash.alert.present?
        klass = "alert"
        text = flash.alert
      elsif text.blank?
        klass = "alert"
        text = I18n.t("error", scope: "decidim.notifications.update")
      end

      render html: ActionController::Base.helpers.content_tag(:div, text, class: "callout #{klass}"), layout: false
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
