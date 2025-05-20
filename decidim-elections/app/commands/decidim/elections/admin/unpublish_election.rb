# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # A command with all the business logic that unpublishes an
      # existing meeting.
      class UnpublishElection < Decidim::Command
        # Public: initializes the command.
        #
        # meeting - Decidim::Elections::Election
        # current_user - the user performing the action
        def initialize(election, current_user)
          @election = election
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless election.published?

          @election = Decidim.traceability.perform_action!(
            :unpublish,
            election,
            current_user,
            visibility: "all"
          ) do
            election.unpublish!
            election
          end
          broadcast(:ok, election)
        end

        private

        attr_reader :election, :current_user
      end
    end
  end
end
