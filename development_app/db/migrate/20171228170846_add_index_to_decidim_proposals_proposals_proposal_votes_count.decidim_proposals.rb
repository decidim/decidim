# This migration comes from decidim_proposals (originally 20170205082832)
# frozen_string_literal: true

class AddIndexToDecidimProposalsProposalsProposalVotesCount < ActiveRecord::Migration[5.0]
  def change
    add_index :decidim_proposals_proposals, :proposal_votes_count
    add_index :decidim_proposals_proposals, :created_at
    add_index :decidim_proposals_proposals, :state
  end
end
