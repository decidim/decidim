# This migration comes from decidim_proposals (originally 20170118120151)
# frozen_string_literal: true

class AddCounterCacheVotesToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_proposals_proposals, :proposal_votes_count, :integer, null: false, default: 0
  end
end
