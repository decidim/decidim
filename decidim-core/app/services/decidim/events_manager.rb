# frozen_string_literal: true

module Decidim
  # This class acts as a wrapper of `ActiveSupport::Notifications`, so that if
  # we ever need to change the API we just have to change it in a single point.
  class EventsManager
    # Publishes a event through the events channel. It requires  the name of an
    # event, a class that handles the event and the resource that received the action.
    #
    # event - a String representing the event that has happened. Ideally, it should
    #   start with `decidim.events` and include the name of the engine that publishes
    #   it.
    # event_class - The event class must be a class that wraps the event name and
    #   the resource and builds the needed information to publish the event to
    #   the different subscribers in the system.
    # resource - an instance of a class that received the event.
    # affected_users - a collection of `Decidim::Users` that are affected by the
    #   event and will receive a notification about it.
    # followers - a collection of `Decidim::Users` that should be notified about
    #   the event, even though it doesn't affect them directly
    # force_send - boolean indicating if EventPublisherJob should skip the
    #   `notifiable?` check it performs before notifying. Defaults to __false__.
    # extra - a Hash with extra information to be included in the notification.
    #
    # Returns nothing.
    # rubocop:disable Metrics/ParameterLists
    def self.publish(event:, resource:, event_class: Decidim::Events::BaseEvent, affected_users: [], followers: [], extra: {}, force_send: false)
      ActiveSupport::Notifications.publish(
        event,
        resource: resource,
        event_class: event_class.name,
        affected_users: affected_users.uniq.compact,
        followers: followers.uniq.compact,
        force_send: force_send,
        extra: extra
      )
    end
    # rubocop:enable Metrics/ParameterLists

    # Subscribes to the given event, and runs the block every time that event
    # is received.
    #
    # event - a String or a RegExp to match against event names.
    #
    # Returns nothing.
    def self.subscribe(event, &block)
      ActiveSupport::Notifications.subscribe(event, &block)
    end
  end
end
