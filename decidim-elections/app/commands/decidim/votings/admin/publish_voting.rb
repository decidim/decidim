# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This command gets called when a voting is published from the admin panel.
      class PublishVoting < Decidim::Command
        # Public: Initializes the command.
        #
        # voting - The voting to publish.
        # current_user - the user performing the action
        def initialize(voting, current_user)
          @voting = voting
          @current_user = current_user
        end

        # Public: Publishes the Voting.
        #
        # Broadcasts :ok if published, :invalid otherwise.
        def call
          return broadcast(:invalid) if voting.nil? || voting.published?

          publish_voting

          broadcast(:ok, voting)
        end

        private

        attr_reader :voting, :current_user

        def publish_voting
          Decidim.traceability.perform_action!(:publish, voting, current_user, visibility: "all") do
            voting.publish!
          end
        end
      end
    end
  end
end
