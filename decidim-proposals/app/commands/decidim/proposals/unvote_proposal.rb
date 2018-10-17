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
          ProposalVote.where(
            author: @current_user,
            proposal: @proposal
          ).destroy_all

          update_temporary_votes
          update_counters
        end

        Decidim::Gamification.decrement_score(@current_user, :proposal_votes)

        broadcast(:ok, @proposal)
      end

      private

      def component
        @component ||= @proposal.component
      end

      def minimum_votes_per_user
        component.settings.minimum_votes_per_user
      end

      def minimum_votes_per_user?
        minimum_votes_per_user.positive?
      end

      # rubocop:disable Rails/SkipsModelValidations
      def update_temporary_votes
        user_votes.update_all(temporary: true) if user_votes.count < minimum_votes_per_user
      end
      # rubocop:enable Rails/SkipsModelValidations

      def user_votes
        @user_votes ||= ProposalVote.where(
          author: @current_user,
          proposal: Proposal.where(component: component)
        )
      end

      def update_counters
        proposal_ids = user_votes.pluck(:decidim_proposal_id) + [@proposal.id]

        proposal_ids.each do |proposal_id|
          Proposal.find(proposal_id).update_votes_count
        end
      end
    end
  end
end
