# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This command is executed when the user joins a conference.
      class ConfirmConferenceRegistration < Decidim::Command
        # Initializes a JoinConference Command.
        #
        # conference_registration - The registration to be confirmed
        def initialize(conference_registration, current_user)
          @conference_registration = conference_registration
          @current_user = current_user
        end

        # Creates a conference registration if the conference has registrations enabled
        # and there are available slots.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) unless can_join_conference?

          @conference_registration.with_lock do
            confirm_registration
            send_email_confirmation
            send_notification_confirmation
          end
          broadcast(:ok)
        end

        private

        attr_reader :conference, :user

        def confirm_registration
          extra_info = {
            resource: {
              title: @conference_registration.conference.title
            }
          }

          Decidim.traceability.perform_action!(
            "confirm",
            @conference_registration,
            @current_user,
            extra_info
          ) do
            @conference_registration.update!(confirmed_at: Time.current)
            @conference_registration
          end
        end

        def can_join_conference?
          @conference_registration.conference.registrations_enabled? && @conference_registration.conference.has_available_slots?
        end

        def send_email_confirmation
          Decidim::Conferences::ConferenceRegistrationMailer.confirmation(
            @conference_registration.user,
            @conference_registration.conference,
            @conference_registration.registration_type
          ).deliver_later
        end

        def send_notification_confirmation
          Decidim::EventsManager.publish(
            event: "decidim.events.conferences.conference_registration_confirmed",
            event_class: Decidim::Conferences::ConferenceRegistrationNotificationEvent,
            resource: @conference_registration.conference,
            affected_users: [@conference_registration.user]
          )
        end
      end
    end
  end
end
