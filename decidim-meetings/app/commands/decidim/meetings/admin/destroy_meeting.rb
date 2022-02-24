# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user destroys a Meeting from the admin
      # panel.
      class DestroyMeeting < Decidim::Command
        # Initializes a CloseMeeting Command.
        #
        # meeting - The current instance of the page to be closed.
        # current_user - the user performing the action
        def initialize(meeting, current_user)
          @meeting = meeting
          @current_user = current_user
        end

        # Destroys the meeting if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid, proposals.size) if proposals.any?

          destroy_meeting
          broadcast(:ok)
        end

        private

        attr_reader :current_user, :meeting

        def destroy_meeting
          Decidim.traceability.perform_action!(
            :delete,
            meeting,
            current_user
          ) do
            meeting.destroy!
          end
        end

        def proposals
          return [] unless Decidim::Meetings.enable_proposal_linking

          @proposals ||= meeting.authored_proposals.load
        end
      end
    end
  end
end
