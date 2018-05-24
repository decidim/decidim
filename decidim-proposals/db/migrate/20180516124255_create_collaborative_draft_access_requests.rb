# frozen_string_literal: true

class CreateCollaborativeDraftAccessRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_proposals_collaborative_draft_access_requests do |t|
      t.belongs_to :decidim_proposals_collaborative_draft, foreign_key: true, index: false
      t.index ["decidim_proposals_collaborative_draft_id"], name: "idx_decidim_proposals_collab_draft_id"
      t.belongs_to :decidim_user, foreign_key: true, index: false
      t.index ["decidim_user_id"], name: "idx_access_requests_on_decidim_user_id"
      # this table should not have updates so no :updated_at
      t.datetime :created_at
    end
  end
end
