# frozen_string_literal: true

require "web-push"

module Decidim
  # This class generates a notification based on the given event, for the given
  # resource/recipient couple. It is intended to be used by the
  # `Decidim::NotificationGenerator` class, which schedules a job for each recipient
  # of the event, so that we can easily control which jobs fail.

  class SendPushNotification
    include ActionView::Helpers::UrlHelper

    # Send the push notification. Returns `nil` if the user did not allowed push notifications
    # or if the subscription to push notifications does not exist
    #
    # @param notification [Decidim::Notification, Decidim::PushNotificationMessage] the notification to be sent
    # @param title [String] the title of the notification. Optional.
    #
    # @return [Array<Net::HTTPCreated>, nil] the result of the dispatch or nil if user or subscription are empty
    def perform(notification, title = nil)
      return if Decidim.vapid_public_key.blank?

      raise ArgumentError, "Need to provide a title if the notification is a PushNotificationMessage" if notification.is_a?(Decidim::PushNotificationMessage) && title.nil?

      user = notification.user

      I18n.with_locale(user.locale || user.organization.default_locale) do
        user.notifications_subscriptions.values.map do |subscription|
          payload = build_payload(message_params(notification, title), subscription)
          # Capture webpush exceptions in order to avoid this call to be repeated by the background job runner
          # Webpush::Error class is the parent class of all defined errors
          begin
            WebPush.payload_send(**payload)
          rescue WebPush::Error => e
            Rails.logger.warn("[ERROR] Push notification delivery failed due to #{e.message}")
            nil
          end
        end.compact
      end
    end

    private

    def message_params(notification, title = nil)
      case notification
      when Decidim::PushNotificationMessage
        notification_params(notification, title)
      else # when Decidim::Notification
        notification_params(Decidim::PushNotificationPresenter.new(notification))
      end
    end

    def notification_params(notification, title = nil)
      {
        title: title.presence || notification.title,
        body: notification.body,
        icon: notification.icon,
        data: { url: notification.url }
      }
    end

    def build_payload(message_params, subscription)
      {
        message: JSON.generate(message_params),
        endpoint: subscription["endpoint"],
        p256dh: subscription["p256dh"],
        auth: subscription["auth"],
        vapid: {
          public_key: Decidim.vapid_public_key,
          private_key: Decidim.vapid_private_key
        }
      }
    end
  end
end
