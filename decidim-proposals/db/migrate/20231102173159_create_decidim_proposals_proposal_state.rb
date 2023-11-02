class CreateDecidimProposalsProposalState < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_proposals_proposal_states do |t|
      t.jsonb :title
      t.jsonb :description
      t.string :token, null: false
      t.boolean :system, null: false, default: false
      t.references :decidim_component, index: true, null: false
      t.integer :proposals_count, default: 0, null: false
      t.boolean :default, default: false, null: false
      t.json :include_in_stats, default: {}, null: false
      t.string :background_color
      t.string :text_color
    end
  end
end
