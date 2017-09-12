# frozen_string_literal: true

module Decidim
  module Meetings
    class UpcomingMeetingNotificationJob < ApplicationJob
      queue_as :decidim_events

      def perform(meeting_id, checksum)
        meeting = Decidim::Meetings::Meeting.find(meeting_id)
        send_notification(meeting) if verify_checksum(meeting, checksum)
      end

      def self.generate_checksum(meeting)
        Digest::MD5.hexdigest("#{meeting.id}-#{meeting.start_time}")
      end

      private

      def send_notification(meeting)
        Decidim::EventsManager.publish(
          event: "decidim.events.meetings.upcoming_meeting",
          event_class: Decidim::Meetings::UpcomingMeetingEvent,
          resource: meeting,
          recipient_ids: meeting.users_to_notify.pluck(:id)
        )
      end

      def verify_checksum(meeting, checksum)
        self.class.generate_checksum(meeting) == checksum
      end
    end
  end
end
