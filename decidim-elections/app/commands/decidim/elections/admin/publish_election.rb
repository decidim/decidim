# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command gets called when a election is published from the admin panel.
      class PublishElection < Rectify::Command
        # Public: Initializes the command.
        #
        # election - The election to publish.
        # current_user - the user performing the action
        def initialize(election, current_user)
          @election = election
          @current_user = current_user
        end

        # Public: Publishes the Election.
        #
        # Broadcasts :ok if published, :invalid otherwise.
        def call
          publish_election
          publish_event

          broadcast(:ok, election)
        end

        private

        attr_reader :election, :current_user

        def publish_election
          Decidim.traceability.perform_action!(
            :publish,
            election,
            current_user,
            visibility: "all"
          ) do
            election.publish!
            election
          end
        end

        def publish_event
          Decidim::EventsManager.publish(
            event: "decidim.events.elections.election_published",
            event_class: ::Decidim::Elections::ElectionPublishedEvent,
            resource: election,
            followers: election.participatory_space.followers
          )
        end
      end
    end
  end
end
