class AddCounterCacheColumnsToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_comments_comments, :up_votes_count, :integer, null: false, default: 0
    add_column :decidim_comments_comments, :down_votes_count, :integer, null: false, default: 0
  end
end
