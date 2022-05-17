# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # notifications settings in their profile page.
  class NotificationsSettingsForm < Form
    mimic :user

    attribute :email_on_moderations, Boolean
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

    def user_is_moderator?(user)
      Decidim.participatory_space_manifests.map do |manifest|
        participatory_space_type = manifest.model_class_name.constantize
        return true if participatory_space_type.moderators(user.organization).exists?(id: user.id)
      end
      false
    end

    def meet_push_notifications_requirements?
      Rails.application.secrets.vapid[:enabled]
    end
  end
end
