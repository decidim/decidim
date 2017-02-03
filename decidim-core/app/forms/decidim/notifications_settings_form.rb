# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # notifications settings in her profile page.
  class NotificationsSettingsForm < Form
    mimic :user

    attribute :comments_notifications
    attribute :replies_notifications
    attribute :newsletter_notifications

    validates :comments_notifications, presence: true
    validates :replies_notifications, presence: true
    validates :newsletter_notifications, presence: true
  end
end
