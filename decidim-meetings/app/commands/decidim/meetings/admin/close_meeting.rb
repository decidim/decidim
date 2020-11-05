# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user closes a Meeting from the admin
      # panel.
      class CloseMeeting < Rectify::Command
        # Initializes a CloseMeeting Command.
        #
        # form - The form from which to get the data.
        # meeting - The current instance of the page to be closed.
        def initialize(form, meeting)
          @form = form
          @meeting = meeting
        end

        # Closes the meeting if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            close_meeting
            link_proposals
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :meeting

        def close_meeting
          Decidim.traceability.perform_action!(
            :close,
            meeting,
            form.current_user
          ) do
            meeting.update!(
              closing_report: form.closing_report,
              attendees_count: form.attendees_count,
              contributions_count: form.contributions_count,
              attending_organizations: form.attending_organizations,
              closed_at: form.closed_at
            )
          end

          Decidim::EventsManager.publish(
            event: "decidim.events.meetings.meeting_closed",
            event_class: Decidim::Meetings::CloseMeetingEvent,
            resource: meeting,
            followers: meeting.followers
          )
        end

        def proposals
          meeting.sibling_scope(:proposals).where(id: @form.proposal_ids)
        end

        def link_proposals
          meeting.link_resources(proposals, "proposals_from_meeting")
        end
      end
    end
  end
end
