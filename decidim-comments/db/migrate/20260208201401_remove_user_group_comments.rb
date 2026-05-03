# frozen_string_literal: true

class RemoveUserGroupComments < ActiveRecord::Migration[7.0]
  def up
    remove_index :decidim_comments_comments, :decidim_user_group_id
    remove_column :decidim_comments_comments, :decidim_user_group_id
  end

  def down
    add_column :decidim_comments_comments, :decidim_user_group_id, :integer
    add_index :decidim_comments_comments, :decidim_user_group_id
  end
end
