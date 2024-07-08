# frozen_string_literal: true

module Decidim
  # This command updates the user's notifications settings.
  class UpdateNotificationsSettings < Decidim::Command
    delegate :current_user, to: :form

    # Updates a user's notifications settings.
    #
    # form - The form with the data.
    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid) unless @form.valid?

      update_notifications_settings
      current_user.save!

      broadcast(:ok, current_user)
    end

    private

    attr_reader :form

    def update_notifications_settings
      current_user.newsletter_notifications_at = @form.newsletter_notifications_at
      current_user.notification_types = @form.notification_types
      current_user.direct_message_types = @form.direct_message_types
      current_user.email_on_moderations = @form.email_on_moderations
      current_user.notification_settings = current_user.notification_settings.merge(@form.notification_settings)
      current_user.notifications_sending_frequency = @form.notifications_sending_frequency
    end
  end
end
