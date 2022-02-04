# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # A command that sets an conference as published.
      class PublishConference < Decidim::Command
        # Public: Initializes the command.
        #
        # conference - A Conference that will be published
        # current_user - the user performing the action
        def initialize(conference, current_user)
          @conference = conference
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if conference.nil? || conference.published?

          Decidim.traceability.perform_action!("publish", conference, current_user) do
            conference.publish!
          end

          broadcast(:ok)
          send_notification
        end

        private

        attr_reader :conference, :current_user

        def send_notification
          return unless conference.registrations_enabled?

          Decidim::EventsManager.publish(
            event: "decidim.events.conferences.registrations_enabled",
            event_class: Decidim::Conferences::ConferenceRegistrationsEnabledEvent,
            resource: conference,
            followers: conference.followers
          )
        end
      end
    end
  end
end
