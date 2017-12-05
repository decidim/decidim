# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user adheres to a proposal.
    class AdhesionProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # proposal     - A Decidim::Proposals::Proposal object.
      # current_user - The current user.
      def initialize(proposal, current_user)
        @proposal = proposal
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        build_proposal_adhesion
        return broadcast(:invalid) unless adhesion.valid?

        adhesion.save!
        broadcast(:ok, adhesion)
      end

      attr_reader :adhesion

      private

      def build_proposal_vote
        @adhesion= @proposal.adhesions.build(author: @current_user)
      end
    end
  end
end
