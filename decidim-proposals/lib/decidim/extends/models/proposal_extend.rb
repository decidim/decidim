# frozen_string_literal: true
# This module is use to add customs methods to the original "proposal.rb"

module ProposalExtend
  def users_to_notify_on_proposal_created
    get_all_users_with_role
  end

  def users_to_notify_on_comment_created
    get_all_users_with_role
  end

  # Public: Override Commentable concern method `users_to_notify_on_comment_authorized`
  def users_to_notify_on_comment_authorized
    return (followers | feature.participatory_space.admins).uniq if official?
    followers
  end

  def create_proposal_moderation
    participatory_space = self.feature.participatory_space
    self.create_moderation!(participatory_space: participatory_space)
  end

  def update_moderation
    unless moderation.upstream_activated?
      moderation.authorize!
    end
  end

  def up_voted_by?(user)
    votes.where(author: user,  proposal: self, weight: 1).any?
  end

  def neutral_voted_by?(user)
    votes.where(author: user,  proposal: self, weight: 0).any?
  end

  def down_voted_by?(user)
    votes.where(author: user,  proposal: self, weight: -1).any?
  end
end

Decidim::Proposals::Proposal.class_eval do
  prepend(ProposalExtend)
  # Votes weight
  has_many :up_votes, -> { where(weight: 1) }, foreign_key: "decidim_proposal_id", class_name: "ProposalVote", dependent: :destroy
  has_many :down_votes, -> { where(weight: -1) }, foreign_key: "decidim_proposal_id", class_name: "ProposalVote", dependent: :destroy
  has_many :neutral_votes, -> { where(weight: 0) }, foreign_key: "decidim_proposal_id", class_name: "ProposalVote", dependent: :destroy

  after_create :create_proposal_moderation
  after_create :update_moderation
end
