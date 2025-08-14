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
        # Note that this could be improved by adding a "type" column to the notifications table
        # This fix can generate lists of notifications that are below the SIZE_LIMIT
        @notifications = notifications[0...SIZE_LIMIT].filter_map do |notification|
          # Check if is a notification that can be sent on email
          next unless notification.event_class_instance.respond_to?(:email_intro)
          # checks if the resource exists, as we have implemented the possibility of soft deleting resources
          next unless resource_is_present?(notification)
          # checks if the notification has been moderated
          next if resource_is_moderated?(notification)
          # checks if the resource is visible
          next unless resource_is_visible?(notification)

          Decidim::NotificationToMailerPresenter.new(notification)
        end

        mail(to: user.email, subject: @notifications_digest.subject) if @notifications.any?
      end
    end

    private

    def resource_is_visible?(notification)
      notification.resource.can_participate?(@user)
    end

    def resource_is_present?(notification)
      notification.resource
    end

    def resource_is_moderated?(notification)
      notification.resource.respond_to?(:hidden?) && notification.resource.hidden?
    end
  end
end
