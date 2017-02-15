# frozen_string_literal: true
module Decidim
  module Proposals
    # A proposal can be reported one time for each user.
    class ProposalReport < ApplicationRecord
      TYPES = %w(spam offensive does_not_belong)
      self.inheritance_column = nil

      belongs_to :proposal, foreign_key: "decidim_proposal_id", class_name: Decidim::Proposals::Proposal
      belongs_to :user, foreign_key: "decidim_user_id", class_name: Decidim::User

      validates :proposal, :user, :type, presence: true
      validates :proposal, uniqueness: { scope: :user }
      validates :type, inclusion: { in: TYPES }
      validate :user_and_proposal_same_organization

      private

      # Private: check if the proposal and the user have the same organization
      def user_and_proposal_same_organization
        return if !proposal || !user
        errors.add(:proposal, :invalid) unless user.organization == proposal.organization
      end
    end
  end
end
