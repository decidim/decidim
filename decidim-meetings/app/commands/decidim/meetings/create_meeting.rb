# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when a participant or user grouo creates a Meeting from the public
    # views.
    class CreateMeeting < Rectify::Command
      def initialize(form)
        @form = form
      end

      # Creates the meeting if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_meeting!
          schedule_upcoming_meeting_notification
          send_notification
        end

        broadcast(:ok, meeting)
      end

      private

      attr_reader :meeting, :form

      def create_meeting!
        parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
        parsed_description = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.description, current_organization: form.current_organization).rewrite
        params = {
          scope: form.scope,
          category: form.category,
          title: parsed_title,
          description: parsed_description,
          end_time: form.end_time,
          start_time: form.start_time,
          address: form.address,
          latitude: form.latitude,
          longitude: form.longitude,
          location: form.location,
          location_hints: form.location_hints,
          private_meeting: form.private_meeting,
          transparent: form.transparent,
          organizer_id: form.organizer.id,
          organizer_type: form.organizer.type,
          registration_terms: form.current_component.settings.default_registration_terms,
          component: form.current_component
        }

        @meeting = Decidim.traceability.create!(
          Meeting,
          form.current_user,
          params,
          visibility: "all"
        )
      end

      def schedule_upcoming_meeting_notification
        checksum = Decidim::Meetings::UpcomingMeetingNotificationJob.generate_checksum(meeting)

        Decidim::Meetings::UpcomingMeetingNotificationJob
          .set(wait_until: meeting.start_time - 2.days)
          .perform_later(meeting.id, checksum)
      end

      def send_notification
        Decidim::EventsManager.publish(
          event: "decidim.events.meetings.meeting_created",
          event_class: Decidim::Meetings::CreateMeetingEvent,
          resource: meeting,
          followers: meeting.participatory_space.followers
        )
      end
    end
  end
end
