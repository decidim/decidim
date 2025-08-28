# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A command with all the business logic that publishes an
      # existing meeting.
      class PublishMeeting < Decidim::Command
        # Public: Initializes the command.
        #
        # meeting - Decidim::Meetings::Meeting
        # current_user - the user performing the action
        def initialize(meeting, current_user)
          @meeting = meeting
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if meeting.published?

          transaction do
            publish_meeting
            send_notification unless meeting.previously_published?
            schedule_upcoming_meeting_notification
          end

          broadcast(:ok, meeting)
        end

        private

        attr_reader :meeting, :current_user

        def publish_meeting
          @meeting = Decidim.traceability.perform_action!(
            :publish,
            meeting,
            current_user,
            visibility: "all"
          ) do
            meeting.publish!
            meeting
          end
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.meetings.meeting_created",
            event_class: Decidim::Meetings::CreateMeetingEvent,
            resource: meeting,
            followers: meeting.participatory_space.followers,
            force_send: true
          )
        end

        def schedule_upcoming_meeting_notification
          return if meeting.start_time < Time.zone.now
          return unless meeting.reminder_enabled

          checksum = Decidim::Meetings::UpcomingMeetingNotificationJob.generate_checksum(meeting)

          Decidim::Meetings::UpcomingMeetingNotificationJob
            .set(wait_until: meeting.start_time - meeting.send_reminders_before_hours.hours)
            .perform_later(meeting.id, checksum)
        end
      end
    end
  end
end
