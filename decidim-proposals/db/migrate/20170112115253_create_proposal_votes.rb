# frozen_string_literal: true

class CreateProposalVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_proposals_proposal_votes do |t|
      t.references :decidim_proposal, null: false, index: { name: "decidim_proposals_proposal_vote_proposal" }
      t.references :decidim_author, null: false, index: { name: "decidim_proposals_proposal_vote_author" }

      t.timestamps
    end

    add_index :decidim_proposals_proposal_votes, [:decidim_proposal_id, :decidim_author_id], unique: true, name: "decidim_proposals_proposal_vote_proposal_author_unique"
  end
end
