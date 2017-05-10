class SetRootCommentableNullConstraints < ActiveRecord::Migration[5.0]
  def change
    change_column :decidim_comments_comments, :decidim_root_commentable_id, :integer, null: false
    change_column :decidim_comments_comments, :decidim_root_commentable_type, :string, null: false
  end
end
