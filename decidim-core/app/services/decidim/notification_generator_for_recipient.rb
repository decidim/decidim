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
    def initialize(event, event_class, resource, recipient_id)
      @event = event
      @event_class = event_class
      @resource = resource
      @recipient_id = recipient_id
    end

    # Generates the notification. Returns `nil` if the resource is not resource
    # or if the resource or the user are not present. It also checks if the resource
    # resource is notifiable for the given recipient, as sometimes we might not want to
    # generate a notification for a given user (a commenter replying to their own comment,
    # or a proposal author updating their own proposal for example).
    #
    # Returns a Decidim::Notification.
    def generate
      return unless event_class
      return unless resource
      return unless recipient
      return unless resource.notifiable?(recipient: recipient, event: event)

      Notification.create!(
        user: recipient,
        event_class: event_class,
        resource: resource,
        event_name: event
      )
    end

    private

    attr_reader :event, :event_class, :resource, :recipient_id

    def recipient
      @recipient ||= User.where(id: recipient_id).first
    end
  end
end
