# frozen_string_literal: true

class AddDeletedAtToDecidimProposalsProposalVotes < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_proposals_proposal_votes, :deleted_at, :datetime
    add_index :decidim_proposals_proposal_votes, :deleted_at
  end
end
