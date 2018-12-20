# frozen_string_literal: true

class RemoveFollowingUsersCountFromUsers < ActiveRecord::Migration[5.2]
  def up
    remove_column :decidim_users, :following_users_count
  end

  def down
    add_column :decidim_users, :following_users_count, :integer, null: false, default: 0

    Decidim::UserBaseEntity.find_each do |entity|
      following_users_count = Decidim::Follow.where(decidim_user_id: entity.id, decidim_followable_type: ["Decidim::UserBaseEntity", "Decidim::User", "Decidim::UserGroup"]).count
      entity.following_users_count = following_users_count
      entity.save
    end
  end
end
