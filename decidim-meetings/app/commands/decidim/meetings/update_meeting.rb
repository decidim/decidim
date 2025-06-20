# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user changes a Meeting from the admin
    # panel.
    class UpdateMeeting < Decidim::Command
      delegate :current_user, to: :form
      # Initializes a UpdateMeeting Command.
      #
      # form - The form from which to get the data.
      # meeting - The current instance of the page to be updated.
      def initialize(form, meeting)
        @form = form
        @meeting = meeting
      end

      # Updates the meeting if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?

        with_events(with_transaction: true) do
          update_meeting!
        end

        send_notification if should_notify_followers?
        schedule_upcoming_meeting_notification if start_time_changed?
        broadcast(:ok, meeting)
      end

      private

      attr_reader :form, :meeting

      def event_arguments
        {
          resource: meeting,
          extra: {
            event_author: current_user,
            locale:
          }
        }
      end

      def update_meeting!
        parsed_title = Decidim::ContentProcessor.parse(form.title, current_organization: form.current_organization).rewrite
        parsed_description = Decidim::ContentProcessor.parse(form.description, current_organization: form.current_organization).rewrite

        Decidim.traceability.update!(
          meeting,
          current_user,
          {
            title: { I18n.locale => parsed_title },
            description: { I18n.locale => parsed_description },
            end_time: form.end_time,
            start_time: form.start_time,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            location: { I18n.locale => form.location },
            location_hints: { I18n.locale => form.location_hints },
            author: current_user,
            registration_type: form.registration_type,
            registration_url: form.registration_url,
            available_slots: form.available_slots,
            registration_terms: { I18n.locale => form.registration_terms },
            registrations_enabled: form.registrations_enabled,
            type_of_meeting: form.clean_type_of_meeting,
            online_meeting_url: form.online_meeting_url,
            iframe_embed_type: form.iframe_embed_type,
            iframe_access_level: form.iframe_access_level,
            taxonomizations: form.taxonomizations
          },
          visibility: "public-only"
        )
      end

      def send_notification
        Decidim::EventsManager.publish(
          event: "decidim.events.meetings.meeting_updated",
          event_class: Decidim::Meetings::UpdateMeetingEvent,
          resource: meeting,
          followers: meeting.followers
        )
      end

      def should_notify_followers?
        important_attributes.any? { |attr| meeting.previous_changes[attr].present? }
      end

      def important_attributes
        %w(start_time end_time address)
      end

      def start_time_changed?
        meeting.previous_changes["start_time"].present?
      end

      def schedule_upcoming_meeting_notification
        return if meeting.start_time < Time.zone.now

        checksum = Decidim::Meetings::UpcomingMeetingNotificationJob.generate_checksum(meeting)

        Decidim::Meetings::UpcomingMeetingNotificationJob
          .set(wait_until: meeting.start_time - Decidim::Meetings.upcoming_meeting_notification)
          .perform_later(meeting.id, checksum)
      end
    end
  end
end
