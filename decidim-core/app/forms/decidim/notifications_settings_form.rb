# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # notifications settings in their profile page.
  class NotificationsSettingsForm < Form
    mimic :user

    attribute :email_on_moderations, Boolean
    attribute :email_on_assigned_proposals, Boolean
    attribute :newsletter_notifications, Boolean
    attribute :notifications_from_followed, Boolean
    attribute :notifications_from_own_activity, Boolean
    attribute :allow_public_contact, Boolean
    attribute :notification_settings, Hash
    attribute :notifications_sending_frequency, String

    def map_model(user)
      self.newsletter_notifications = user.newsletter_notifications_at.present?
      self.notifications_from_followed = ["all", "followed-only"].include? user.notification_types
      self.notifications_from_own_activity = ["all", "own-only"].include? user.notification_types
      self.allow_public_contact = user.direct_message_types == "all"
      self.notifications_sending_frequency = user.notifications_sending_frequency
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

    def meet_push_notifications_requirements?
      Decidim.vapid_public_key.present?
    end
  end
end
