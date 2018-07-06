# frozen_string_literal: true

module Decidim
  module Conferences
    # This command is executed when the user leaves a conference.
    class LeaveConference < Rectify::Command
      # Initializes a LeaveConference Command.
      #
      # conference - The current instance of the conference to be left.
      # user - The user leaving the conference.
      def initialize(conference, user)
        @conference = conference
        @user = user
      end

      # Destroys a conference registration if the conference has registrations enabled
      # and the registration exists.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        @conference.with_lock do
          return broadcast(:invalid) unless registration
          destroy_registration
        end
        broadcast(:ok)
      end

      private

      def registration
        @registration ||= Decidim::Conferences::Registration.find_by(conference: @conference, user: @user)
      end

      def destroy_registration
        registration.destroy!
      end
    end
  end
end
