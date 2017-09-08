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
    # recipient_ids - an Array of IDs of the users that will receive the event
    # extra - a Hash with extra information to be included in the notification.
    #
    # Returns nothing.
    def self.publish(event:, event_class: Decidim::Events::BaseEvent, resource:, recipient_ids:, extra: {})
      ActiveSupport::Notifications.publish(
        event,
        event_class: event_class.name,
        resource: resource,
        recipient_ids: recipient_ids,
        extra: extra
      )
    end

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
