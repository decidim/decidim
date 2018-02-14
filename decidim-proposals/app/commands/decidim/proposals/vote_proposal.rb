# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user votes a proposal.
    class VoteProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # proposal     - A Decidim::Proposals::Proposal object.
      # current_user - The current user.
      def initialize(proposal, current_user, weight)
        @proposal = proposal
        @current_user = current_user
        @weight = weight
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal vote.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @proposal.maximum_votes_reached?

        build_proposal_vote
        return broadcast(:invalid) unless vote.valid?

        vote.save!
        broadcast(:ok, vote)
      end

      attr_reader :vote

      private

      def build_proposal_vote
        @vote = @proposal.votes.find_or_initialize_by(author: current_user)
        @vote.update_attributes!(weight: @weight)
      end
    end
  end
end
