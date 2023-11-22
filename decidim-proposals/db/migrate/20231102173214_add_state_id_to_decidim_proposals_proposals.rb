# frozen_string_literal: true

class AddStateIdToDecidimProposalsProposals < ActiveRecord::Migration[6.1]
  def up
    add_column :decidim_proposals_proposals, :decidim_proposals_proposal_state_id, :integer, index: true, null: false

    add_foreign_key :decidim_proposals_proposals, :decidim_proposals_proposal_states, column: :decidim_proposals_proposal_state_id
  end

  def down
    remove_foreign_key :decidim_proposals_proposals, column: :decidim_proposals_proposal_state_id
    remove_column :decidim_proposals_proposals, :decidim_proposals_proposal_state_id
  end
end
