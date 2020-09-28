# frozen_string_literal: true

class AddCommentableCounterCacheToProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_proposals_proposals, :comments_count, :integer, null: false, default: 0, index: true
    add_column :decidim_proposals_collaborative_drafts, :comments_count, :integer, null: false, default: 0, index: true
    Decidim::Proposals::Proposal.reset_column_information
    Decidim::Proposals::Proposal.find_each(&:update_comments_count)
    Decidim::Proposals::CollaborativeDraft.reset_column_information
    Decidim::Proposals::CollaborativeDraft.find_each(&:update_comments_count)
  end
end
