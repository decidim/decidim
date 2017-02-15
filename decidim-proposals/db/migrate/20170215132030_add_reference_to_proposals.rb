class AddReferenceToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_proposals_proposals, :reference, :string
  end
end
