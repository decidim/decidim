# frozen_string_literal: true

class RemoveUserGroupCore < ActiveRecord::Migration[7.0]
  def up
    remove_index :decidim_coauthorships, :decidim_user_group_id
    remove_column :decidim_coauthorships, :decidim_user_group_id
    remove_index :decidim_likes, :decidim_user_group_id
    remove_column :decidim_likes, :decidim_user_group_id
  end

  def down
    add_column :decidim_coauthorships, :decidim_user_group_id, :integer
    add_index :decidim_coauthorships, :decidim_user_group_id
    add_column :decidim_likes, :decidim_user_group_id, :integer
    add_index :decidim_likes, :decidim_user_group_id
  end
end
