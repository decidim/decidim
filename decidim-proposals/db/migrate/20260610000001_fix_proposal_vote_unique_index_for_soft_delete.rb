# frozen_string_literal: true

class FixProposalVoteUniqueIndexForSoftDelete < ActiveRecord::Migration[8.1]
  def up
    remove_index :decidim_proposals_proposal_votes,
                 name: "decidim_proposals_proposal_vote_proposal_author_unique"

    add_index :decidim_proposals_proposal_votes,
              [:decidim_proposal_id, :decidim_author_id],
              unique: true,
              where: "deleted_at IS NULL",
              name: "decidim_proposals_proposal_vote_proposal_author_unique"
  end

  def down
    remove_index :decidim_proposals_proposal_votes,
                 name: "decidim_proposals_proposal_vote_proposal_author_unique"

    add_index :decidim_proposals_proposal_votes,
              [:decidim_proposal_id, :decidim_author_id],
              unique: true,
              name: "decidim_proposals_proposal_vote_proposal_author_unique"
  end
end
