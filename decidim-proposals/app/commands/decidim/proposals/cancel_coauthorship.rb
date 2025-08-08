# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user cancels an invitation to be a coauthor.
    class CancelCoauthorship < Decidim::Command
      # Public: Initializes the command.
      #
      # proposal     - The proposal to add a coauthor to.
      # coauthor - The user to invite as coauthor.
      def initialize(proposal, coauthor)
        @proposal = proposal
        @coauthor = coauthor
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the coauthor is not valid.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @coauthor
        return broadcast(:invalid) if @proposal.authors.include?(@coauthor)

        @proposal.coauthor_invitations_for(@coauthor).destroy_all

        broadcast(:ok)
      end
    end
  end
end
