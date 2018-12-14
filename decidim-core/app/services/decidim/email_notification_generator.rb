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
    # followers - a collection of Users that receive the notification because
    #   they're following it
    # affected_users - a collection of Users that receive the notification because
    #   they're affected by it
    # extra - a Hash with extra information to be included in the notification.
    # rubocop:disable Metrics/ParameterLists
    def initialize(event, event_class, resource, followers, affected_users, extra)
      @event = event
      @event_class = event_class
      @resource = resource
      @followers = followers
      @affected_users = affected_users
      @extra = extra
    end
    # rubocop:enable Metrics/ParameterLists

    # Schedules a job for each recipient to send the email. Returns `nil`
    # if the resource is not resource or if it is not present.
    #
    # Returns nothing.
    def generate
      return unless resource
      return unless event_class.types.include?(:email)

      followers.each do |recipient|
        next unless ["all", "followed-only"].include?(recipient.notification_types)
        send_email_to(recipient)
      end

      affected_users.each do |recipient|
        next unless ["all", "own-only"].include?(recipient.notification_types)
        send_email_to(recipient)
      end
    end

    private

    attr_reader :event, :event_class, :resource, :followers, :affected_users, :extra

    # Private: sends the notification email to the user if they have the
    # `email_on_notification` flag active.
    #
    # recipient - The user that will receive the email.
    #
    # Returns nothing.
    def send_email_to(recipient)
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
