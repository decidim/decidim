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
end

Decidim::Proposals::Proposal.class_eval do
  prepend(ProposalExtend)
  after_create :create_proposal_moderation
  after_create :update_moderation
end
