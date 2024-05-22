# frozen_string_literal: true

module Decidim
  # A custom mailer for sending notifications to users when
  # a events are received.
  class NotificationsDigestMailer < Decidim::ApplicationMailer
    helper Decidim::ResourceHelper
    SIZE_LIMIT = 10

    def digest_mail(user, notification_ids)
      with_user(user) do
        notifications = Decidim::Notification.where(id: notification_ids)
        @user = user
        @organization = user.organization
        @notifications_digest = Decidim::NotificationsDigestPresenter.new(user)
        @display_see_more_message = notifications.size > SIZE_LIMIT
        @notifications = notifications[0...SIZE_LIMIT].map { |notification| Decidim::NotificationToMailerPresenter.new(notification) }

        mail(to: user.email, subject: @notifications_digest.subject)
      end
    end
  end
end
