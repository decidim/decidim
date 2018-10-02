# frozen_string_literal: true

module Decidim
  module Conferences
    # This command is executed when the user joins a conference.
    class JoinConference < Rectify::Command
      # Initializes a JoinConference Command.
      #
      # conference - The current instance of the conference to be joined.
      # user - The user joining the conference.
      def initialize(conference, user)
        @conference = conference
        @user = user
      end

      # Creates a conference registration if the conference has registrations enabled
      # and there are available slots.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        conference.with_lock do
          return broadcast(:invalid) unless can_join_conference?
          create_registration
          create_meetings_registrations
          accept_invitation
          send_email_confirmation
          send_notification
        end
        broadcast(:ok)
      end

      private

      attr_reader :conference, :user

      def accept_invitation
        conference.conference_invites.find_by(user: user)&.accept!
      end

      def create_registration
        Decidim::Conferences::ConferenceRegistration.create!(conference: conference, user: user)
      end

      def create_meetings_registrations
        published_meeting_components = Decidim::Component.where(participatory_space: conference).where(manifest_name: "meetings").published
        meetings = Decidim::Meetings::Meeting.where(component: published_meeting_components)

        meetings.each do |meeting|
          Decidim::Meetings::Registration.create!(meeting: meeting, user: user)
        end
      end

      def can_join_conference?
        conference.registrations_enabled? && conference.has_available_slots?
      end

      def send_email_confirmation
        Decidim::Conferences::ConferenceRegistrationMailer.confirmation(user, conference).deliver_later
      end

      def participatory_space_admins
        @conference.admins
      end

      def send_notification
        return send_notification_over(0.5) if occupied_slots_over?(0.5)
        return send_notification_over(0.8) if occupied_slots_over?(0.8)
        send_notification_over(1.0) if occupied_slots_over?(1.0)
      end

      def send_notification_over(percentage)
        Decidim::EventsManager.publish(
          event: "decidim.events.conferences.conference_registrations_over_percentage",
          event_class: Decidim::Conferences::ConferenceRegistrationsOverPercentageEvent,
          resource: @conference,
          recipient_ids: participatory_space_admins.pluck(:id),
          extra: {
            percentage: percentage
          }
        )
      end

      def occupied_slots_over?(percentage)
        @conference.remaining_slots == (@conference.available_slots * (1 - percentage)).round
      end
    end
  end
end
