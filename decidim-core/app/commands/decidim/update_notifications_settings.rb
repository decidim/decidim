# frozen_string_literal: true

module Decidim
  # This command updates the user's notifications settings.
  class UpdateNotificationsSettings < Decidim::Command
    # Updates a user's notifications settings.
    #
    # user - The user to be updated.
    # form - The form with the data.
    def initialize(user, form)
      @user = user
      @form = form
    end

    def call
      return broadcast(:invalid) unless @form.valid?

      update_notifications_settings
      @user.save!

      broadcast(:ok, @user)
    end

    private

    def update_notifications_settings
      @user.newsletter_notifications_at = @form.newsletter_notifications_at
      @user.notification_types = @form.notification_types
      @user.direct_message_types = @form.direct_message_types
      @user.email_on_moderations = @form.email_on_moderations
      @user.notification_settings = @user.notification_settings.merge(@form.notification_settings)
      @user.notifications_sending_frequency = @form.notifications_sending_frequency
    end
  end
end
