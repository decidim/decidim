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
    # user - the User that performed the event.
    #
    # Returns nothing.
    def self.publish(event:, event_class: Decidim::Events::BaseEvent, resource:, user:)
      ActiveSupport::Notifications.publish(
        event,
        event_class: event_class.name,
        resource: resource,
        user: user
      )
    end
  end
end
