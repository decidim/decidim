# frozen_string_literal: true

module Decidim
  module Proposals
    # A proposal can include a vote per user.
    class ProposalVote < ApplicationRecord
      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal", counter_cache: true
      belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User"

      validates :proposal, uniqueness: { scope: :author }
      validate :author_and_proposal_same_organization
      validate :proposal_not_rejected

      after_save :update_proposal_votes_counter
      after_destroy :update_proposal_votes_counter

      def self.temporary
        where(temporary: true)
      end

      def self.final
        where(temporary: false)
      end

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

      def update_proposal_votes_counter
        proposal.update_vote_count
      end
    end
  end
end
