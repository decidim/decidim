# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user joins a meeting waitlist.
    class JoinWaitlist < Decidim::Command
      delegate :current_user, to: :form

      def initialize(meeting, form)
        @meeting = meeting
        @form = form
      end

      def call
        return broadcast(:invalid) unless can_join_waitlist?
        return broadcast(:invalid_form) unless form.valid?

        meeting.with_lock do
          create_waitlist_entry
          send_waitlist_notification
        end

        broadcast(:ok)
      end

      private

      attr_reader :meeting, :user_group, :form

      def can_join_waitlist?
        meeting.waitlist_enabled? && !meeting.registrations.exists?(user: current_user) && !meeting.has_available_slots?
      end

      def create_waitlist_entry
        @registration = Decidim::Meetings::Registration.create!(
          meeting:,
          user: current_user,
          public_participation: form.public_participation,
          status: :waiting_list
        )
      end

      def send_waitlist_notification
        Decidim::EventsManager.publish(
          event: "decidim.events.meetings.meeting_waitlist_added",
          event_class: Decidim::Meetings::MeetingRegistrationNotificationEvent,
          resource: meeting,
          affected_users: [current_user]
        )
      end
    end
  end
end
