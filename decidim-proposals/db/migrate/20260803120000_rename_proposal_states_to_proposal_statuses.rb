# frozen_string_literal: true

class RenameProposalStatesToProposalStatuses < ActiveRecord::Migration[7.0]
  def up
    rename_index :decidim_proposals_proposal_states, :index_decidim_proposals_proposal_states_on_decidim_component_id, :index_decidim_proposals_proposal_statuses_on_component_id
    rename_table :decidim_proposals_proposal_states, :decidim_proposals_proposal_statuses
    rename_column :decidim_proposals_proposals, :decidim_proposals_proposal_state_id, :decidim_proposals_proposal_status_id
    rename_column :decidim_proposals_proposals, :state_published_at, :status_published_at
  end

  def down
    rename_column :decidim_proposals_proposals, :status_published_at, :state_published_at
    rename_column :decidim_proposals_proposals, :decidim_proposals_proposal_status_id, :decidim_proposals_proposal_state_id
    rename_index :decidim_proposals_proposal_statuses, :index_decidim_proposals_proposal_statuses_on_component_id, :index_decidim_proposals_proposal_states_on_decidim_component_id
    rename_table :decidim_proposals_proposal_statuses, :decidim_proposals_proposal_states
  end
end
