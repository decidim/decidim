# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This command gets called when a election is setup from the admin panel.
      class SetupElection < Rectify::Command
        # Public: Initializes the command.
        #
        # election - The election to setup.
        # current_user - the user performing the action
        def initialize(election, current_user)
          @election = election
          @current_user = current_user
        end

        # Public: Setup the Election.
        #
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          setup_election

          broadcast(:ok, election)
        end

        private

        attr_reader :election, :current_user

        def setup_election
          Decidim.traceability.perform_action!(
            :setup,
            election,
            current_user,
            visibility: "all"
          ) do
            election.setup!
            election
          end
        end
      end
    end
  end
end
