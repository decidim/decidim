class AddUserGroupIdToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_comments_comments, :decidim_user_group_id, :integer, index: true
  end
end
