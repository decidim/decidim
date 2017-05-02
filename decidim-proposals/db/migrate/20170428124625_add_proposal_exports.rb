class AddProposalExports < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_proposal_exports do |t|
      t.references :decidim_proposal, index: true, null: false
      t.string :file_url
      t.string :status

      t.timestamps
    end
  end
end
