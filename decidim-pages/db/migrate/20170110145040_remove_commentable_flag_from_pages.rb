class RemoveCommentableFlagFromPages < ActiveRecord::Migration[5.0]
  def change
    remove_column :decidim_pages_pages, :commentable
  end
end
