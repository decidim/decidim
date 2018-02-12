class AddWeightOnProposalsVotes < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_proposals_proposal_votes, :weight, :integer, null: :false
  end
end
