# frozen_string_literal: true

class AddFollowingAndFollowersCountersToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :decidim_users, :following_count, :integer, null: false, default: 0
    add_column :decidim_users, :following_users_count, :integer, null: false, default: 0
    add_column :decidim_users, :followers_count, :integer, null: false, default: 0

    Decidim::UserBaseEntity.find_each do |entity|
      follower_count = Decidim::Follow.where(followable: entity).count
      following_count = Decidim::Follow.where(decidim_user_id: entity.id).count
      following_users_count = Decidim::Follow.where(decidim_user_id: entity.id, decidim_followable_type: ["Decidim::UserBaseEntity", "Decidim::User", "Decidim::UserGroup"]).count

      entity.followers_count = follower_count
      entity.following_count = following_count
      entity.following_users_count = following_users_count
      entity.save
    end
  end

  def down
    remove_column :decidim_users, :following_count
    remove_column :decidim_users, :following_users_count
    remove_column :decidim_users, :followers_count
  end
end
