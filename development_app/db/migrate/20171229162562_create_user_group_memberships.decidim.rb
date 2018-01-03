# This migration comes from decidim (originally 20170119150255)
# frozen_string_literal: true

class CreateUserGroupMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_user_group_memberships do |t|
      t.references :decidim_user, null: false, index: true
      t.references :decidim_user_group, null: false, index: true

      t.timestamps
    end

    add_index :decidim_user_group_memberships, [:decidim_user_id, :decidim_user_group_id], unique: true, name: "decidim_user_group_memberships_unique_user_and_group_ids"
  end
end
