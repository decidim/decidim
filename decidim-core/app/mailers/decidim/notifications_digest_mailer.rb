# frozen_string_literal: true

module Decidim
  # A custom mailer for sending notifications to users when
  # a events are received.
  class NotificationsDigestMailer < Decidim::ApplicationMailer
    helper Decidim::ResourceHelper

    def digest_mail(user, notification_ids)
      with_user(user) do
        notifications = Decidim::Notification.where(id: notification_ids)
        size_limit = 10
        @user = user
        @organization = user.organization
        @notifications_digest = Decidim::NotificationsDigestPresenter.new(user)
        @display_see_more_message = notifications.size > size_limit
        @notifications = notifications[0...size_limit].map { |notification| Decidim::NotificationToMailerPresenter.new(notification) }

        mail(to: user.email, subject: @notifications_digest.subject)
      end
    end
  end
end
