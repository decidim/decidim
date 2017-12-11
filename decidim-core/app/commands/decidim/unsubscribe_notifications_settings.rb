# frozen_string_literal: true

module Decidim
  # This command unsubscribe user from newsletter.
  class UnsubscribeNotificationsSettings < Rectify::Command
    # unsubscribe user from newsletter.
    #
    # user - The user to be updated.
    # newsletter_notifications - to be false
    def initialize(user, unsubscribe)
      @user = user
      @unsubscribe = unsubscribe
    end

    def call
      return broadcast(:invalid) unless @user.newsletter_notifications

      update_notifications_settings
      @user.save!

      broadcast(:ok, @user)
    end

    private

    def update_notifications_settings
      @user.newsletter_notifications = @unsubscribe
    end
  end
end
