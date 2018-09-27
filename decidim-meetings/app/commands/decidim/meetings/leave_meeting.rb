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

      # Destroys a meeting registration if the meeting has registrations enabled
      # and the registration exists.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        @meeting.with_lock do
          return broadcast(:invalid) unless registration
          destroy_registration
          decrement_score
        end
        broadcast(:ok)
      end

      private

      def registration
        @registration ||= Decidim::Meetings::Registration.find_by(meeting: @meeting, user: @user)
      end

      def destroy_registration
        registration.destroy!
      end

      def decrement_score
        Decidim::Gamification.decrement_score(@user, :attended_meetings)
      end
    end
  end
end
