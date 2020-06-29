# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This command is executed when the user destroys a Meeting from the admin
      # panel.
      class DestroyMeeting < Rectify::Command
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
          if proposals.any?
            broadcast(:invalid, proposals.count)
          else
            destroy_meeting
            broadcast(:ok)
          end
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
          @proposals ||= Decidim::Proposals::Proposal
                         .joins(:coauthorships)
                         .where(decidim_coauthorships: {
                           decidim_author_type: "Decidim::Meetings::Meeting",
                           decidim_author_id: meeting.id
                         })
        end
      end
    end
  end
end
