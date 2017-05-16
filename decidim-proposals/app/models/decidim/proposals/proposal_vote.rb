# frozen_string_literal: true
module Decidim
  module Proposals
    # A proposal can include a vote per user.
    class ProposalVote < ApplicationRecord
      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal", counter_cache: true
      belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User"

      validates :proposal, :author, presence: true
      validates :proposal, uniqueness: { scope: :author }
      validate :author_and_proposal_same_organization

      private

      # Private: check if the proposal and the author have the same organization
      def author_and_proposal_same_organization
        return if !proposal || !author
        errors.add(:proposal, :invalid) unless author.organization == proposal.organization
      end
    end
  end
end
