# frozen_string_literal: true

module Decidim
  # This command unsubscribes user from newsletter.
  class UnsubscribeSettings < Rectify::Command
    # unsubscribe user from newsletter.
    #
    # user - The user to be updated.
    # newsletter_notifications - to be false
    def initialize(user)
      @user = user
    end

    def call
      return broadcast(:invalid) unless @user.newsletter_notifications

      update_settings
      @user.save!

      broadcast(:ok, @user)
    end

    private

    def update_settings
      @user.newsletter_notifications = false
    end
  end
end
