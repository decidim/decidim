# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # notifications settings in her profile page.
  class NotificationsSettingsForm < Form
    mimic :user

    attribute :email_on_notification
    attribute :newsletter_notifications

    validates :email_on_notification, presence: true
    validates :newsletter_notifications, presence: true

    def newsletter_notifications_at
      return nil unless newsletter_notifications
      Time.current
    end

    def map_model(model)
      self.newsletter_notifications = model.newsletter_notifications_at.present?
    end
  end
end
