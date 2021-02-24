# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # notifications settings in her profile page.
  class NotificationsSettingsForm < Form
    mimic :user

    attribute :email_on_notification, Boolean
    attribute :email_on_moderations, Boolean
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

    def user_is_moderator?(user)
      participatory_space_types.each do |participatory_space_type|
        participatory_space_type.constantize.all.each do |participatory_space|
          return true if participatory_space.moderators.include?(user)
        end
      end
      false
    end

    private

    def participatory_space_types
      participatory_space_types = []
      Decidim.participatory_space_manifests.each do |manifest|
        participatory_space_types << manifest.model_class_name.to_s
      end
      participatory_space_types
    end
  end
end
