# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user leaves a meeting.
    class LeaveMeeting < Rectify::Command
      # Initializes a LeaveMeeting Command.
      #
      # meeting - The current instance of the meeting to be left.
      # user - The user leaving the meeting.
      def initialize(meeting, user)
        @meeting = meeting
        @user = user
      end

      # Destroys a meeting inscription if the meeting has inscriptions enabled
      # and the inscription exists.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        @meeting.with_lock do
          destroy_inscription
        end
        broadcast(:ok)
      end

      private

      def inscription
        @inscription ||= Decidim::Meetings::Inscription.where(meeting: @meeting, user: @user).first
      end

      def destroy_inscription
        inscription.destroy!
      end
    end
  end
end
