class AddOfficialImageProposalToProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_proposals_proposals, :official_image_proposal, :string
  end
end
