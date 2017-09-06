# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user changes a Meeting from the admin
      # panel.
      class UpdateMeeting < Rectify::Command
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

          transaction do
            update_meeting!
            send_notification if should_notify_followers?
          end

          broadcast(:ok, meeting)
        end

        private

        attr_reader :form, :meeting

        def update_meeting!
          meeting.update_attributes!(
            scope: form.scope,
            category: form.category,
            title: form.title,
            description: form.description,
            end_time: form.end_time,
            start_time: form.start_time,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            location: form.location,
            location_hints: form.location_hints
          )
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.meetings.meeting_updated",
            event_class: Decidim::Meetings::UpdateMeetingEvent,
            resource: meeting,
            recipient_ids: meeting.users_to_notify.pluck(:id),
            user: form.current_user
          )
        end

        def should_notify_followers?
          important_attributes.any? { |attr| meeting.previous_changes[attr].present? }
        end

        def important_attributes
          %w(start_time end_time address)
        end
      end
    end
  end
end
