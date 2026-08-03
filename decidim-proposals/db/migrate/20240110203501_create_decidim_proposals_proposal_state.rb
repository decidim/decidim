# frozen_string_literal: true

class CreateDecidimProposalsProposalState < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_proposals_proposal_states do |t|
      t.jsonb :title
      t.jsonb :announcement_title
      t.string :token, null: false
      t.references :decidim_component, index: true, null: false
      t.integer :proposals_count, default: 0, null: false
      t.string :bg_color, default: "#F6F8FA", null: false
      t.string :text_color, default: "#4B5058", null: false
    end
  end
end
