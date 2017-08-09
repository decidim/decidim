# frozen_string_literal: true

module Decidim
  # This class handles system events affecting `Decidim::Followable` resources and
  # generates a notification for each follower by scheduling a new
  # `Decidim::NotificationGeneratorForFollowerJob` job for each of them. This way
  # we can easily control which jobs fail and retry them, so that we don't have
  # duplicated notifications.
  class NotificationGenerator
    # Initializes the class.
    #
    # event - A String with the name of the event.
    # followable - an instance of a class implementing the `Decidim::Followable` concern.
    def initialize(event, followable)
      @event = event
      @followable = followable
    end

    # Schedules a job for each follower to create the notification. Returns `nil`
    # if the resource is not followable or if it is not present.
    #
    # Returns a Decidim::Notification.
    def generate
      return unless followable
      return unless followable.is_a?(Followable)

      followable.users_to_notify.each do |followable|
        generate_notification_for(followable)
      end
    end

    private

    attr_reader :event, :followable

    def generate_notification_for(follower)
      NotificationGeneratorForFollowerJob.perform_later(
        event,
        followable,
        follower
      )
    end
  end
end
