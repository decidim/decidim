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
    # Returns the result of the dispatch
    def perform(notification)
      user = notification.user
      return unless user.allow_push_notifications

      subscription = Decidim::NotificationsSubscription.find_by(user: user)
      return unless subscription

      message_params = notification_params(notification)
      payload = payload(message_params, subscription) # Replace sus to suscription

      Webpush.payload_send(payload)
    end

    private

    def notification_params(notification)
      {
        title: notification.event_class.constantize.model_name.human,
        body: ActionView::Base.full_sanitizer.sanitize(notification.event_class_instance.notification_title),
        icon: notification.user.organization.attached_uploader(:favicon).variant_url(:big, host: notification.user.organization.host),
        url: notification.resource.reported_content_url
      }
    end

    def payload(message_params, suscription)
      {
        message: JSON.generate(message_params),
        endpoint: suscription.endpoint,
        p256dh: suscription.p256dh,
        auth: suscription.auth,
        vapid: {
          public_key: public_key,
          private_key: private_key
        }
      }
    end

    def public_key
      ENV["VAPID_PUBLIC_KEY"]
    end

    def private_key
      ENV["VAPID_PRIVATE_KEY"]
    end
  end
end
