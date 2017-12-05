# frozen_string_literal: true

module Decidim
  # This class handles system events affecting resources and generates a
  # notification for each recipient by scheduling a new
  # `Decidim::NotificationMailer` job for each of them. This way we can
  # easily control which jobs fail and retry them, so that we don't have
  # duplicated notifications.
  class EmailNotificationGenerator
    # Initializes the class.
    #
    # event - A String with the name of the event.
    # event_class - A class that wraps the event.
    # resource - an instance of a class implementing the `Decidim::Resource` concern.
    # extra - a Hash with extra information to be included in the notification.
    def initialize(event, event_class, resource, recipient_ids, extra)
      @event = event
      @event_class = event_class
      @resource = resource
      @recipient_ids = recipient_ids
      @extra = extra
    end

    # Schedules a job for each recipient to send the email. Returns `nil`
    # if the resource is not resource or if it is not present.
    #
    # Returns nothing.
    def generate
      return unless resource
      return unless event_class.types.include?(:email)

      recipient_ids.each do |recipient_id|
        send_email_to(recipient_id)
      end
    end

    private

    attr_reader :event, :event_class, :resource, :recipient_ids, :extra

    # Private: sends the notification email to the user if they have the
    # `email_on_notification` flag active.
    #
    # recipient_id - The ID of the user that will receive the email.
    #
    # Returns nothing.
    def send_email_to(recipient_id)
      recipient = Decidim::User.where(id: recipient_id).first
      return unless recipient
      return unless recipient.email_on_notification?

      NotificationMailer
        .event_received(
          event,
          event_class.name,
          resource,
          recipient,
          extra
        )
        .deliver_later
    end
  end
end
