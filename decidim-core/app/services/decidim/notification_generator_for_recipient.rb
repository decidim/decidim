# frozen_string_literal: true

module Decidim
  # This class generates a notification based on the given event, for the given
  # resource/recipient couple. It is intended to be used by the
  # `Decidim::NotificationGenerator` class, which schedules a job for each recipient
  # of the event, so that we can easily control which jobs fail.
  class NotificationGeneratorForRecipient
    # Initializes the class.
    #
    # event - A String with the name of the event.
    # event_class - The class that wraps the event, in order to decorate it.
    # resource - an instance of a class implementing the `Decidim::Resource` concern.
    # recipient - the ID of the User that will receive the notification.
    # extra - a Hash with extra information to be included in the notification.
    def initialize(event, event_class, resource, recipient_id, extra)
      @event = event
      @event_class = event_class
      @resource = resource
      @recipient_id = recipient_id
      @extra = extra
    end

    # Generates the notification. Returns `nil` if the resource is not resource
    # or if the resource or the user are not present.
    #
    # Returns a Decidim::Notification.
    def generate
      return unless event_class
      return unless resource
      return unless recipient

      Notification.create!(
        user: recipient,
        event_class: event_class,
        resource: resource,
        event_name: event,
        extra: extra
      )
    end

    private

    attr_reader :event, :event_class, :resource, :recipient_id, :extra

    def recipient
      @recipient ||= User.where(id: recipient_id).first
    end
  end
end
