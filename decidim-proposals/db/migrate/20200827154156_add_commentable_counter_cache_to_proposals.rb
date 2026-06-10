# frozen_string_literal: true

class AddCommentableCounterCacheToProposals < ActiveRecord::Migration[5.2]
  class Proposal < ApplicationRecord
    self.table_name = "decidim_proposals_proposals"
  end

  class CollaborativeDraft < ApplicationRecord
    self.table_name = "decidim_proposals_collaborative_drafts"
  end

  def change
    add_column :decidim_proposals_proposals, :comments_count, :integer, null: false, default: 0, index: true
    add_column :decidim_proposals_collaborative_drafts, :comments_count, :integer, null: false, default: 0, index: true
    Proposal.reset_column_information
    Proposal.unscoped.find_each(&:update_comments_count)
    CollaborativeDraft.unscoped.reset_column_information
    CollaborativeDraft.unscoped.find_each(&:update_comments_count)
  end
end
