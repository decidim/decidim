# frozen_string_literal: true

module Decidim
  # This class handles system events affecting resources and generates a
  # notification for each recipient by scheduling a new
  # `Decidim::NotificationGeneratorForRecipientJob` job for each of them. This way
  # we can easily control which jobs fail and retry them, so that we don't have
  # duplicated notifications.
  class NotificationGenerator
    # Initializes the class.
    #
    # event - A String with the name of the event.
    # event_class - A class that wraps the event.
    # resource - an instance of a class implementing the `Decidim::Resource` concern.
    # followers - a collection of Users that receive the notification because
    #   they're following it
    # affected_users - a collection of Users that receive the notification because
    #   they're affected by it
    # extra - a Hash with extra information for the event.
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

    # Schedules a job for each recipient to create the notification. Returns `nil`
    # if the resource is not resource or if it is not present.
    #
    # Returns nothing.
    def generate
      return unless resource
      return unless event_class.types.include?(:notification)

      followers.each do |recipient|
        generate_notification_for(recipient, user_role: :follower) if ["all", "followed-only"].include?(recipient.notification_types)
      end

      affected_users.each do |recipient|
        generate_notification_for(recipient, user_role: :affected_user) if ["all", "own-only"].include?(recipient.notification_types)
      end
    end

    private

    attr_reader :event, :event_class, :resource, :followers, :affected_users, :extra

    def generate_notification_for(recipient, user_role:)
      return if resource.respond_to?(:can_participate?) && !resource.can_participate?(recipient)

      NotificationGeneratorForRecipientJob.perform_later(
        event,
        event_class.name,
        resource,
        recipient,
        user_role.to_s,
        extra
      )
    end
  end
end
