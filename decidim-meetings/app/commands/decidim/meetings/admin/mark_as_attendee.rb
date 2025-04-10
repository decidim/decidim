# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user marks a registration as attendee
      # from the admin panel.
      class MarkAsAttendee < Decidim::Command
        def initialize(registration)
          @registration = registration
        end

        def call
          return broadcast(:invalid) if registration.validated?

          mark_attendee
          send_notification

          broadcast(:ok)
        end

        attr_reader :registration

        protected

        def mark_attendee
          registration.update!(validated_at: Time.current)
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.meetings.registration_marked_as_attendee",
            event_class: Decidim::Meetings::RegistrationMarkedAsAttendeeEvent,
            resource: meeting,
            affected_users: [registration.user],
            extra: {
              registration: registration
            }
          )
        end
      end
    end
  end
end
