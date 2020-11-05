# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command gets called when a election is unpublished from the admin panel.
      class UnpublishElection < Rectify::Command
        # Public: Initializes the command.
        #
        # election - The election to unpublish.
        # current_user - the user performing the action
        def initialize(election, current_user)
          @election = election
          @current_user = current_user
        end

        # Public: Unpublishes the Election.
        #
        # Broadcasts :ok if unpublished, :invalid otherwise.
        def call
          unpublish_election

          broadcast(:ok)
        end

        private

        attr_reader :election, :current_user

        def unpublish_election
          Decidim.traceability.perform_action!(
            :unpublish,
            election,
            current_user
          ) do
            election.unpublish!
            election
          end
        end
      end
    end
  end
end
