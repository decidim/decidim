# frozen_string_literal: true

# This module is use to add customs methods to the original "proposal.rb"

module ProposalExtend
  include Decidim::HasClassExtends

  def up_voted_by?(user)
    votes.where(author: user, proposal: self, weight: 1).any?
  end

  def neutral_voted_by?(user)
    votes.where(author: user, proposal: self, weight: 0).any?
  end

  def down_voted_by?(user)
    votes.where(author: user, proposal: self, weight: -1).any?
  end

  def weighted_by?(user, value)
    case value
    when "up" then
      up_voted_by?(user)
    when "neutral" then
      neutral_voted_by?(user)
    when "down" then
      down_voted_by?(user)
    else
      false
    end
  end

  def users_to_notify_on_proposal_created
    users_with_role
  end

  def users_to_notify_on_comment_created
    users_with_role
  end
end

Decidim::Proposals::Proposal.class_eval do
  prepend(ProposalExtend)
  # Votes weight
  has_many :up_votes, -> { where(weight: 1) }, foreign_key: "decidim_proposal_id", class_name: "ProposalVote", dependent: :destroy
  has_many :down_votes, -> { where(weight: -1) }, foreign_key: "decidim_proposal_id", class_name: "ProposalVote", dependent: :destroy
  has_many :neutral_votes, -> { where(weight: 0) }, foreign_key: "decidim_proposal_id", class_name: "ProposalVote", dependent: :destroy
end
