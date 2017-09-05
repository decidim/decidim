# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user joins a meeting.
    class JoinMeeting < Rectify::Command
      # Initializes a JoinMeeting Command.
      #
      # meeting - The current instance of the meeting to be joined.
      # user - The user joining the meeting.
      def initialize(meeting, user)
        @meeting = meeting
        @user = user
      end

      # Creates a meeting registration if the meeting has registrations enabled
      # and there are available slots.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        meeting.with_lock do
          return broadcast(:invalid) unless can_join_meeting?
          create_registration
          send_email_confirmation
          send_notification
        end
        broadcast(:ok)
      end

      private

      attr_reader :meeting, :user

      def create_registration
        Decidim::Meetings::Registration.create!(meeting: meeting, user: user)
      end

      def can_join_meeting?
        meeting.registrations_enabled? && meeting.has_available_slots?
      end

      def send_email_confirmation
        RegistrationMailer.confirmation(user, meeting).deliver_later
      end

      def participatory_space_admins
        @meeting.feature.participatory_space.admins
      end

      def send_notification
        return send_notification_over(0.5) if occupied_slots_over?(0.5)
        return send_notification_over(0.8) if occupied_slots_over?(0.8)
      end

      def send_notification_over(percentage)
        Decidim::EventsManager.publish(
          event: "decidim.events.meetings.meeting_registrations_over_percentage",
          event_class: Decidim::Meetings::MeetingRegistrationsOverPercentage,
          resource: @meeting,
          recipient_ids: participatory_space_admins.pluck(:id),
          extra: {
            user: @user,
            percentage: percentage
          }
        )
      end

      def occupied_slots_over?(percentage)
        @meeting.remaining_slots == (@meeting.available_slots * (1 - percentage)).floor
      end
    end
  end
end
