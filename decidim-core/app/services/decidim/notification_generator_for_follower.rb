# frozen_string_literal: true

module Decidim
  # This class generates a notification based on the given event, for the given
  # followable/follower couple. It is intended to be used by the
  # `Decidim::NotificationGenerator` class, which schedules a job for each follower
  # of the followable resource, so that we can easily control which jobs fail.
  class NotificationGeneratorForFollower
    # Initializes the class.
    #
    # event - A String with the name of the event.
    # event_class - The class that wraps the event, in order to decorate it.
    # followable - an instance of a class implementing the `Decidim::Followable` concern.
    # follower - the User that is following the followable resource and will receive the
    #   notification.
    def initialize(event, event_class, followable, follower)
      @event = event
      @event_class = event_class
      @followable = followable
      @follower = follower
    end

    # Generates the notification. Returns `nil` if the resource is not followable
    # or if the resource or the user are not present. It also checks if the followable
    # resource is notifiable for the given follower, as sometimes we might not want to
    # generate a notification for a given user (a commenter replying to their own comment,
    # or a proposal author updating their own proposal for example).
    #
    # Returns a Decidim::Notification.
    def generate
      return unless event_class
      return unless followable
      return unless followable.is_a?(Followable)
      return unless follower
      return unless followable.notifiable?(follower: follower)

      Notification.create!(
        user: follower,
        event_class: event_class,
        followable: followable,
        notification_type: event
      )
    end

    private

    attr_reader :event, :event_class, :followable, :follower
  end
end
