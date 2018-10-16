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

      def self.temporary
        where(temporary: true)
      end

      def self.final
        where(temporary: false)
      end

      def self.update_temporary_votes!(user, proposal)
        component = proposal.component

        user_votes = ProposalVote.where(
          author: user,
          proposal: Proposal.where(component: component)
        )

        vote_count = user_votes.count

        if vote_count >= component.settings.minimum_votes_per_user
          user_votes.map { |vote| vote.update!(temporary: false) }
        else
          user_votes.map { |vote| vote.update!(temporary: true) }
        end

        proposal_ids = user_votes.map { |vote| vote.proposal.id }.compact.uniq + [proposal.id]

        proposal_ids.map do |proposal_id|
          proposal = Proposal.find(proposal_id)
          proposal.update(proposal_votes_count: proposal.votes.count)
        end
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
    end
  end
end
