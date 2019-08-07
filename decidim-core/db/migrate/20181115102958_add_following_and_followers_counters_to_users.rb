# frozen_string_literal: true

class AddFollowingAndFollowersCountersToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :decidim_users, :following_count, :integer, null: false, default: 0
    add_column :decidim_users, :following_users_count, :integer, null: false, default: 0
    add_column :decidim_users, :followers_count, :integer, null: false, default: 0
  end

  def down
    remove_column :decidim_users, :following_count
    remove_column :decidim_users, :following_users_count
    remove_column :decidim_users, :followers_count
  end
end
