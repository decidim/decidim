# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # notifications settings in her profile page.
  class NotificationsSettingsForm < Form
    mimic :user

    attribute :email_on_notification, Boolean
    attribute :newsletter_notifications, Boolean
    attribute :notifications_from_followed, Boolean
    attribute :notifications_from_own_activity, Boolean
    attribute :allow_public_contact, Boolean

    def map_model(user)
      self.newsletter_notifications = user.newsletter_notifications_at.present?
      self.notifications_from_followed = ["all", "followed-only"].include? user.notification_types
      self.notifications_from_own_activity = ["all", "own-only"].include? user.notification_types
      self.allow_public_contact = user.direct_message_types == "all"
    end

    def newsletter_notifications_at
      return nil unless newsletter_notifications

      Time.current
    end

    def notification_types
      if notifications_from_followed && notifications_from_own_activity
        "all"
      elsif notifications_from_followed
        "followed-only"
      elsif notifications_from_own_activity
        "own-only"
      else
        "none"
      end
    end

    def direct_message_types
      allow_public_contact ? "all" : "followed-only"
    end
  end
end
