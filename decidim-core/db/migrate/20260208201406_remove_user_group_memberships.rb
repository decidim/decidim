# frozen_string_literal: true

class RemoveUserGroupMemberships < ActiveRecord::Migration[7.0]
  def up
    drop_table :decidim_user_group_memberships
  end

  def down
    create_table "decidim_user_group_memberships", id: :serial, force: :cascade do |t|
      t.integer "decidim_user_id", null: false
      t.integer "decidim_user_group_id", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "role", default: "requested", null: false
      t.index %w(decidim_user_group_id decidim_user_id), name: "index_user_group_memberships_group_id_user_id"
      t.index ["decidim_user_group_id"], name: "index_decidim_user_group_memberships_on_decidim_user_group_id"
      t.index %w(decidim_user_id decidim_user_group_id), name: "decidim_user_group_memberships_unique_user_and_group_ids", unique: true
      t.index ["decidim_user_id"], name: "index_decidim_user_group_memberships_on_decidim_user_id"
      t.index %w(role decidim_user_group_id), name: "decidim_group_membership_one_creator_per_group", unique: true, where: "((role)::text = 'creator'::text)"
    end
  end
end
