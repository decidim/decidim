# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user or organization unendorses a proposal.
    class UnendorseProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # proposal     - A Decidim::Proposals::Proposal object.
      # current_user - The current user.
      # current_group- (optional) The current_group that is unendorsing from the Proposal.
      def initialize(proposal, current_user, current_group = nil)
        @proposal = proposal
        @current_user = current_user
        @current_group = current_group
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        destroy_proposal_endorsement
        broadcast(:ok, @proposal)
      end

      private

      def destroy_proposal_endorsement
        query = @proposal.endorsements.where(
          author: @current_user,
          decidim_user_group_id: @current_group&.id
        )
        query.destroy_all
      end
    end
  end
end
