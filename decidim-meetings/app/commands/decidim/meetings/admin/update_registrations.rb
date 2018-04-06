# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user updates the meeting registrations.
      class UpdateRegistrations < Rectify::Command
        # Initializes a UpdateRegistrations Command.
        #
        # form - The form from which to get the data.
        # meeting - The current instance of the meeting to be updated.
        def initialize(form, meeting)
          @form = form
          @meeting = meeting
        end

        # Updates the meeting if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          meeting.with_lock do
            return broadcast(:invalid) if form.invalid?
            update_meeting_registrations
            send_notification if should_notify_followers?
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :meeting

        def update_meeting_registrations
          meeting.registrations_enabled = form.registrations_enabled

          if form.registrations_enabled
            meeting.available_slots = form.available_slots
            meeting.reserved_slots = form.reserved_slots
            meeting.registration_terms = form.registration_terms
          end

          meeting.save!
        end

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.meetings.registrations_enabled",
            event_class: Decidim::Meetings::MeetingRegistrationsEnabledEvent,
            resource: meeting,
            recipient_ids: meeting.followers.pluck(:id)
          )
        end

        def should_notify_followers?
          meeting.previous_changes["registrations_enabled"].present? && meeting.registrations_enabled?
        end
      end
    end
  end
end
