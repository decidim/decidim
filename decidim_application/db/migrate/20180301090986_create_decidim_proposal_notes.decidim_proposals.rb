# This migration comes from decidim_proposals (originally 20180111110204)
# frozen_string_literal: true

class CreateDecidimProposalNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_proposals_proposal_notes do |t|
      t.references :decidim_proposal, null: false, index: { name: "decidim_proposals_proposal_note_proposal" }
      t.references :decidim_author, null: false, index: { name: "decidim_proposals_proposal_note_author" }
      t.text :body, null: false

      t.timestamps
    end

    add_column :decidim_proposals_proposals, :proposal_notes_count, :integer, null: false, default: 0
  end
end
