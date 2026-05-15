# frozen_string_literal: true

module Decidim
  module Conferences
    class UpcomingConferenceNotificationJob < ApplicationJob
      queue_as :events

      def perform(conference_id, checksum)
        conference = Decidim::Conference.find(conference_id)
        send_notification(conference) if verify_checksum(conference, checksum)
      end

      def self.generate_checksum(conference)
        Digest::SHA256.hexdigest("#{conference.id}-#{conference.start_date}")
      end

      private

      def send_notification(conference)
        Decidim::EventsManager.publish(
          event: "decidim.events.conferences.upcoming_conference",
          event_class: Decidim::Conferences::UpcomingConferenceEvent,
          resource: conference,
          followers: conference.followers
        )
      end

      def verify_checksum(conference, checksum)
        self.class.generate_checksum(conference) == checksum
      end
    end
  end
end
