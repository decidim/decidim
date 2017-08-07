# frozen_string_literal: true

module Decidim
  # This class acts as a wrapper of `ActiveSupport::Notifications`, so that if
  # we ever need to change the API we just have to change it in a single point.
  class EventsManager
    # Publishes a event through the events channel. It requires  the name of an
    # event, a class that handles the event and a `Followable` resource.
    #
    # event - a String representing the event that has happened. Ideally, it should
    #   start with `decidim.events` and include the name of the engine that publishes
    #   it.
    # event_class - The event class must be a class that wraps the event name and
    #   the resource and builds the needed information to publish the event to
    #   the different subscribers in the system.
    # followable - an instance of a class implementing the `Followable` module.
    #
    # Returns nothing.
    def self.publish(event:, event_class: Decidim::Events::BaseEvent, followable:)
      ActiveSupport::Notifications.publish(
        event,
        event_class: event_class.name.underscore,
        followable: followable
      )
    end
  end
end
