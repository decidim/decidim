# frozen_string_literal: true

module Decidim
  module Meetings
    # Background job that promotes users from the waitlist to registered status,
    # depending on available slots in the meeting.
    class PromoteFromWaitlistJob < ApplicationJob
      queue_as :default

      def perform(meeting_id)
        @meeting = Decidim::Meetings::Meeting.find_by(id: meeting_id)
        return unless @meeting

        promote_users_from_waitlist
      end

      private

      attr_reader :meeting

      def promote_users_from_waitlist
        meeting.with_lock do
          loop do
            break unless meeting.remaining_slots.positive?

            next_in_waitlist = meeting.registrations.on_waiting_list.first
            break unless next_in_waitlist

            promote(next_in_waitlist)
          end
        end
      end

      def promote(registration)
        return unless registration.waiting_list?

        registration.update!(status: :registered)
        notify_user(registration)
      end

      def notify_user(registration)
        send_email_confirmation(registration)
        send_internal_notification(registration)
      end

      def send_email_confirmation(registration)
        Decidim::Meetings::RegistrationMailer.confirmation(registration.user, meeting, registration).deliver_later
      end

      def send_internal_notification(registration)
        Decidim::EventsManager.publish(
          event: "decidim.events.meetings.meeting_registration_confirmed",
          event_class: Decidim::Meetings::MeetingRegistrationNotificationEvent,
          resource: meeting,
          affected_users: [registration.user],
          extra: {
            registration_code: registration.code
          }
        )
      end
    end
  end
end
