# frozen_string_literal: true

class DropCollaborativeDraftsTables < ActiveRecord::Migration[7.2]
  def up
    drop_table :decidim_proposals_collaborative_drafts, if_exists: true
    drop_table :decidim_proposals_collaborative_draft_collaborator_requests, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
