# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user unvotes a proposal.
    class UnvoteProposal < Rectify::Command
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
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        ActiveRecord::Base.transaction do
          votes = @proposal.votes.where(author: @current_user)
          Decidim::Gamification.decrement_score(@current_user, :proposal_votes, votes.count)
          votes.destroy_all
        end

        broadcast(:ok, @proposal)
      end
    end
  end
end
