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
    add_index :decidim_likes,
              [:decidim_likable_id, :decidim_likable_type, :decidim_author_id, :decidim_author_type, :decidim_user_group_id],
              name: "idx_likes_rsrcs_and_authors",
              unique: true
  end
end
