# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user declines an invite to the meeting.
    class DeclineInvitation < Decidim::Command
      # Initializes a DeclineInvitation Command.
      #
      # meeting - The current instance of the meeting where user has been invited.
      # user - The user that declines their invitation
      def initialize(meeting, user)
        @meeting = meeting
        @user = user
      end

      # Creates a meeting registration if the meeting has registrations enabled
      # and there are available slots.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless can_decline_invitation?

        decline_invitation

        broadcast(:ok)
      end

      private

      attr_reader :meeting, :user

      def decline_invitation
        invitation.decline!
      end

      def can_decline_invitation?
        meeting.registrations_enabled? && invitation.present?
      end

      def invitation
        @invitation ||= meeting.invites.find_by(user:)
      end
    end
  end
end
