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
    # extra - a Hash with extra information for the event.
    def initialize(event, event_class, resource, recipient_ids, extra)
      @event = event
      @event_class = event_class
      @resource = resource
      @recipient_ids = recipient_ids
      @extra = extra
    end

    # Schedules a job for each recipient to create the notification. Returns `nil`
    # if the resource is not resource or if it is not present.
    #
    # Returns nothing.
    def generate
      return unless resource
      return unless event_class.types.include?(:notification)

      recipient_ids.each do |recipient_id|
        generate_notification_for(recipient_id)
      end
    end

    private

    attr_reader :event, :event_class, :resource, :recipient_ids, :extra

    def generate_notification_for(recipient_id)
      NotificationGeneratorForRecipientJob.perform_later(
        event,
        event_class.name,
        resource,
        recipient_id,
        extra
      )
    end
  end
end
