# frozen_string_literal: true

module Decidim
  module Meetings
    # This command is executed when the user joins a meeting.
    class JoinMeeting < Rectify::Command
      # Initializes a JoinMeeting Command.
      #
      # meeting - The current instance of the meeting to be joined.
      # user - The user joining the meeting.
      def initialize(meeting, user)
        @meeting = meeting
        @user = user
      end

      # Creates a meeting inscription if the meeting has inscriptions enabled
      # and available slots.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        @meeting.with_lock do
          create_inscription
        end
        broadcast(:ok)
      end

      private

      def create_inscription
        Decidim::Meetings::Inscription.create!(meeting: @meeting, user: @user)
      end
    end
  end
end
