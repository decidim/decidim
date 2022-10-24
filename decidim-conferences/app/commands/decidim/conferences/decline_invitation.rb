# frozen_string_literal: true

module Decidim
  module Conferences
    # This command is executed when the user declines an invite to the conference.
    class DeclineInvitation < Decidim::Command
      # Initializes a DeclineInvitation Command.
      #
      # conference - The current instance of the conference where user has been invited.
      # user - The user that declines their invitation
      def initialize(conference, user)
        @conference = conference
        @user = user
      end

      # Creates a conference registration if the conference has registrations enabled
      # and there are available slots.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless can_decline_invitation?

        decline_invitation

        broadcast(:ok)
      end

      private

      attr_reader :conference, :user

      def decline_invitation
        invitation.decline!
      end

      def can_decline_invitation?
        conference.registrations_enabled? && invitation.present?
      end

      def invitation
        @invitation ||= conference.conference_invites.find_by(user:)
      end
    end
  end
end
