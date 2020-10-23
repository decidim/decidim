# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user closes a Meeting from the public
    # views.
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
        parsed_closing_report = Decidim::ContentProcessor.parse(form.closing_report, current_organization: form.current_organization).rewrite

        Decidim.traceability.perform_action!(
          :close,
          meeting,
          form.current_user
        ) do
          meeting.update!(
            closed_at: form.closed_at,
            closing_report: { I18n.locale => parsed_closing_report }
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
