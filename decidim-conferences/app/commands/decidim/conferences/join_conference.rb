# frozen_string_literal: true

module Decidim
  module Conferences
    # This command is executed when the user joins a conference.
    class JoinConference < Decidim::Command
      # Initializes a JoinConference Command.
      #
      # conference - The current instance of the conference to be joined.
      # registration_type - The registration type selected to attend the conference
      # user - The user joining the conference.
      def initialize(conference, registration_type, user)
        @conference = conference
        @registration_type = registration_type
        @user = user
      end

      # Creates a conference registration if the conference has registrations enabled
      # and there are available slots.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless can_join_conference?

        conference.with_lock do
          create_registration
          create_meetings_registrations
          accept_invitation
          send_email_pending_validation
          send_notification_pending_validation
          notify_admin_over_percentage
        end
        broadcast(:ok)
      end

      private

      attr_reader :conference, :user

      def accept_invitation
        conference.conference_invites.find_by(user:)&.accept!
      end

      def create_registration
        Decidim::Conferences::ConferenceRegistration.create!(conference:, user:, registration_type: @registration_type)
      end

      def create_meetings_registrations
        published_meeting_components = Decidim::Component.where(participatory_space: conference).where(manifest_name: "meetings").published
        meetings = Decidim::Meetings::Meeting.where(component: published_meeting_components).where(id: @registration_type.conference_meetings.pluck(:id))

        meetings.each do |meeting|
          Decidim::Meetings::Registration.create!(meeting:, user:)
        end
      end

      def can_join_conference?
        conference.registrations_enabled? && conference.has_available_slots?
      end

      def send_email_pending_validation
        Decidim::Conferences::ConferenceRegistrationMailer.pending_validation(user, conference, @registration_type).deliver_later
      end

      def send_notification_pending_validation
        Decidim::EventsManager.publish(
          event: "decidim.events.conferences.conference_registration_validation_pending",
          event_class: Decidim::Conferences::ConferenceRegistrationNotificationEvent,
          resource: @conference,
          affected_users: [@user]
        )
      end

      def participatory_space_admins
        @conference.admins
      end

      def notify_admin_over_percentage
        return send_notification_over(0.5) if occupied_slots_over?(0.5)
        return send_notification_over(0.8) if occupied_slots_over?(0.8)

        send_notification_over(1.0) if occupied_slots_over?(1.0)
      end

      def send_notification_over(percentage)
        Decidim::EventsManager.publish(
          event: "decidim.events.conferences.conference_registrations_over_percentage",
          event_class: Decidim::Conferences::ConferenceRegistrationsOverPercentageEvent,
          resource: @conference,
          followers: participatory_space_admins,
          extra: {
            percentage:
          }
        )
      end

      def occupied_slots_over?(percentage)
        @conference.remaining_slots == (@conference.available_slots * (1 - percentage)).round
      end
    end
  end
end
