# frozen_string_literal: true

module Decidim
  module Events
    # This class serves as a base for all event classes. Event classes are intended to
    # add more logic to a `Decidim::Notification` and are used to render them in the
    # notifications dashboard and to generate other notifications (emails, for example).
    class BaseEvent
      # Initializes the class.
      #
      # event_name - a String with the name of the event.
      # payload - a Hash with extra data from the event.
      def initialize(event_name, payload)
        @event_name = event_name
        @payload = payload
      end

      private

      attr_reader :event_name, :payload
    end
  end
end
