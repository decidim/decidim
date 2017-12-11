class AddCounterCacheAdhesionsToProposals < ActiveRecord::Migration[5.1]
  def change
  	add_column :decidim_proposals_proposals, :proposal_adhesions_count, :integer, null: false, default: 0
  	add_index  :decidim_proposals_proposals, :proposal_adhesions_count
  end
end
