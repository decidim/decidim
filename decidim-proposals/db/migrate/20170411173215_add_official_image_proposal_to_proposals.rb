class AddOfficialImageProposalToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_proposals_proposals, :image, :string
  end
end
