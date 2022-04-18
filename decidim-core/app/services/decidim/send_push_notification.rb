# frozen_string_literal: true

require "webpush"

module Decidim
  # This class generates a notification based on the given event, for the given
  # resource/recipient couple. It is intended to be used by the
  # `Decidim::NotificationGenerator` class, which schedules a job for each recipient
  # of the event, so that we can easily control which jobs fail.

  class SendPushNotification
    include ActionView::Helpers::UrlHelper

    # Send the push notification. Returns `nil` if the user didn't allowed push notifications
    # or if the subscription to push notifications doesn't exist
    #
    # Returns the result of the dispatch or nil if user or subscription are empty
    def perform(notification)
      return unless Rails.application.secrets.vapid[:enabled]

      notification.user.notifications_subscriptions.values.map do |subscription|
        message_params = notification_params(Decidim::PushNotificationPresenter.new(notification))
        payload = payload(message_params, subscription)
        Webpush.payload_send(payload)
      end
    end

    def notification_params(notification)
      {
        title: notification.title,
        body: notification.body,
        icon: notification.icon,
        data: { url: notification.url }
      }
    end

    def payload(message_params, subscription)
      {
        message: JSON.generate(message_params),
        endpoint: subscription["endpoint"],
        p256dh: subscription["p256dh"],
        auth: subscription["auth"],
        vapid: {
          public_key: Rails.application.secrets.vapid[:public_key],
          private_key: Rails.application.secrets.vapid[:private_key]
        }
      }
    end
  end
end
