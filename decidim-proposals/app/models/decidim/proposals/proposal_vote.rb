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

      after_save :update_proposal_votes_count
      after_destroy :update_proposal_votes_count

      # Temporary votes are used when a minimum amount of votes is configured in
      # a component. They are not taken into account unless the amount of votes
      # exceeds a threshold - meanwhile, they are marked as temporary.
      def self.temporary
        where(temporary: true)
      end

      # Final votes are votes that will be taken into account, that is, they are
      # not temporary.
      def self.final
        where(temporary: false)
      end

      private

      def update_proposal_votes_count
        proposal.update_votes_count
        proposal.touch # rubocop:disable Rails/SkipsModelValidations
      end

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
