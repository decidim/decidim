class CreateProposalAdhesions < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_proposals_proposal_adhesions do |t|
      t.references :decidim_proposal, null: false, index: { name: "decidim_proposals_proposal_adhesion_proposal" }
      t.references :decidim_author, null: false, index: { name: "decidim_proposals_proposal_adhesion_author" }

      t.timestamps
    end

    add_index :decidim_proposals_proposal_adhesions, [:decidim_proposal_id, :decidim_author_id], unique: true, name: "decidim_proposals_proposal_adhesion_proposal_author_unique"
  end
end
