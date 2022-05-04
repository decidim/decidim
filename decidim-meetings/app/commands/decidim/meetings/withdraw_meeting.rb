# frozen_string_literal: true

module Decidim
  module Meetings
    # A command with all the business logic when a user withdraws a new proposal.
    class WithdrawMeeting < Decidim::Command
      # Public: Initializes the command.
      #
      # meeting     - The meeting to withdraw.
      # current_user - The current user.
      def initialize(meeting, current_user)
        @meeting = meeting
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the meeting.
      # - :invalid if the meeting does not belong to current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @meeting.authored_by?(@current_user)

        transaction do
          change_meeting_state_to_withdrawn
        end

        broadcast(:ok, @meeting)
      end

      private

      def change_meeting_state_to_withdrawn
        @meeting.update state: "withdrawn"
      end
    end
  end
end
