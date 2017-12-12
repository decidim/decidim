class CreateProposalAdhesions < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_proposals_proposal_adhesions do |t|
      t.references :decidim_proposal, null: false, index: { name: "decidim_proposals_proposal_adhesion_proposal" }
      t.references :decidim_author, null: false, index: { name: "decidim_proposals_proposal_adhesion_author" }
      t.references :decidim_user_group, null: true, index: { name: 'decidim_proposals_proposal_adhesion_user_group' }

      t.timestamps
    end

    add_index :decidim_proposals_proposal_adhesions, [:decidim_proposal_id, :decidim_author_id, :decidim_user_group_id], unique: true, name: "decidim_proposals_proposal_adhesion_proposal_auth_ugroup_unique"
  end
end
