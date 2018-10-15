# frozen_string_literal: true

module Decidim
  module Proposals
    # A proposal can include a vote per user.
    class ProposalVote < ApplicationRecord
      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal"
      belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User"

      validates :proposal, uniqueness: { scope: :author }
      validate :author_and_proposal_same_organization
      validate :proposal_not_rejected

      after_save :update_temporary_votes
      after_destroy :update_temporary_votes

      def self.temporary
        where(temporary: true)
      end

      def self.final
        where(temporary: false)
      end

      # rubocop:disable Rails/SkipsModelValidations
      def update_temporary_votes
        user_votes = ProposalVote.where(
          author: author,
          proposal: Proposal.where(component: proposal.component)
        )

        vote_count = user_votes.count

        if vote_count >= proposal.component.settings.minimum_votes_per_user
          user_votes.update_all(temporary: false)
        else
          user_votes.update_all(temporary: true)
        end

        proposal.update_vote_counter

        user_votes.each do |vote|
          vote.proposal.update_vote_counter
        end
      end
      # rubocop:enable Rails/SkipsModelValidations

      private

      # Private: check if the proposal and the author have the same organization
      def author_and_proposal_same_organization
        return if !proposal || !author
        errors.add(:proposal, :invalid) unless author.organization == proposal.organization
      end

      def proposal_not_rejected
        return unless proposal
        errors.add(:proposal, :invalid) if proposal.rejected?
      end
    end
  end
end
