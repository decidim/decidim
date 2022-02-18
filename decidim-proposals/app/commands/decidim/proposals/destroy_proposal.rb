# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user destroys a draft proposal.
    class DestroyProposal < Decidim::Command
      # Public: Initializes the command.
      #
      # proposal     - The proposal to destroy.
      # current_user - The current user.
      def initialize(proposal, current_user)
        @proposal = proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid and the proposal is deleted.
      # - :invalid if the proposal is not a draft.
      # - :invalid if the proposal's author is not the current user.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless @proposal.draft?
        return broadcast(:invalid) unless @proposal.authored_by?(@current_user)

        @proposal.destroy!

        broadcast(:ok, @proposal)
      end
    end
  end
end
