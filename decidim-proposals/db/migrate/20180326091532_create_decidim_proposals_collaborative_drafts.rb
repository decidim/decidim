# frozen_string_literal: true

class CreateDecidimProposalsCollaborativeDrafts < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_proposals_collaborative_drafts do |t|
      t.text "title", null: false
      t.text "body", null: false
      t.integer "decidim_component_id", null: false
      t.integer "decidim_scope_id"
      t.string "state"
      t.string "reference"
      t.text "address"
      t.float "latitude"
      t.float "longitude"
      t.datetime "published_at"
      t.integer "authors_count", default: 0, null: false
      t.integer "versions_count", default: 0, null: false
      t.integer "contributions_count", default: 0, null: false
      t.index ["body"], name: "decidim_proposals_collaborative_draft_body_search"
      t.index ["updated_at"], name: "decidim_proposals_collaborative_drafts_on_updated_at"
      t.index ["decidim_component_id"], name: "decidim_proposals_collaborative_drafts_on_decidim_component_id"
      t.index ["decidim_scope_id"], name: "decidim_proposals_collaborative_drafts_on_decidim_scope_id"
      t.index ["state"], name: "decidim_proposals_collaborative_drafts_on_state"
      t.index ["title"], name: "decidim_proposals_collaborative_drafts_title_search"

      t.timestamps
    end
  end
end
