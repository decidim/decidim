# frozen_string_literal: true

module Decidim
  module Proposals
    # A proposal can include an adhesion per user or group.
    class ProposalAdhesion < ApplicationRecord
      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: "Decidim::Proposals::Proposal", counter_cache: true
      belongs_to :author, foreign_key: "decidim_author_id", class_name: "Decidim::User"
      belongs_to :user_group, foreign_key: "decidim_user_group_id", class_name: "Decidim::UserGroup", optional: true

      validates :proposal, uniqueness: { scope: [:author, :user_group] }
      validate :author_and_proposal_same_organization
      validate :proposal_not_rejected

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
