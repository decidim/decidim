# frozen_string_literal: true

module Decidim
  module Events
    # This class serves as a base for all event classes. Event classes are intended to
    # add more logic to a `Decidim::Notification` and are used to render them in the
    # notifications dashboard and to generate other notifications (emails, for example).
    class BaseEvent
      # Public: Stores all the notification types this event can create. Please, do not
      # overwrite this method, consider it final. Instead, add values to the array via
      # modules, take the `NotificationEvent` module as an example:
      #
      # Example:
      #
      #   module WebPushNotificationEvent
      #     extend ActiveSupport::Concern
      #
      #     included do
      #       types << :web_push_notifications
      #     end
      #   end
      #
      #   class MyEvent < Decidim::Events::BaseEvent
      #     include WebPushNotificationEvent
      #   end
      #
      #   MyEvent.types # => [:web_push_notifications]
      def self.types
        @types ||= []
      end

      # Initializes the class.
      #
      # event_name - a String with the name of the event.
      # payload - an optional Hash with extra data from the event.
      def initialize(event_name, payload = {})
        @event_name = event_name
        @payload = payload
      end

      private

      attr_reader :event_name, :payload
    end
  end
end
