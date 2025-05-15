class RenameProposalsEndorsementsCountToLikes < ActiveRecord::Migration[7.0]
  def change
    rename_column :decidim_proposals_proposals, :endorsements_count, :likes_count
  end
end
