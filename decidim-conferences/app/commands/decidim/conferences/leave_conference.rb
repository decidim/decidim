# frozen_string_literal: true

module Decidim
  module Conferences
    # This command is executed when the user leaves a conference.
    class LeaveConference < Decidim::Command
      # Initializes a LeaveConference Command.
      #
      # conference - The current instance of the conference to be left.
      # registration_type - The registration type selected to attend the conference
      # user - The user leaving the conference.
      def initialize(conference, registration_type, user)
        @conference = conference
        @registration_type = registration_type
        @user = user
      end

      # Destroys a conference registration if the conference has registrations enabled
      # and the registration exists.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless registration
        return broadcast(:invalid) unless meetings_registrations

        @conference.with_lock do
          destroy_registration
          destroy_meeting_registration
        end
        broadcast(:ok)
      end

      private

      def registration
        @registration ||= Decidim::Conferences::ConferenceRegistration.find_by(conference: @conference, user: @user, registration_type: @registration_type)
      end

      def destroy_registration
        registration.destroy!
      end

      def meetings_registrations
        published_meeting_components = Decidim::Component.where(participatory_space: @conference).where(manifest_name: "meetings").published
        meetings = Decidim::Meetings::Meeting.where(component: published_meeting_components).where(id: @registration_type.conference_meetings.pluck(:id))

        @meetings_registrations ||= Decidim::Meetings::Registration.where(meeting: meetings, user: @user)
      end

      def destroy_meeting_registration
        meetings_registrations.each(&:destroy!)
      end
    end
  end
end
