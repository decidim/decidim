# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # A command with all the business logic that unpublishes an
      # existing meeting.
      class UnpublishMeeting < Decidim::Command
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
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless meeting.published?

          @meeting = Decidim.traceability.perform_action!(
            :unpublish,
            meeting,
            current_user,
            visibility: "all"
          ) do
            meeting.unpublish!
            meeting
          end
          broadcast(:ok, meeting)
        end

        private

        attr_reader :meeting, :current_user
      end
    end
  end
end
