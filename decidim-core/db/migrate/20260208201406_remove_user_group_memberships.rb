# frozen_string_literal: true

class RemoveUserGroupMemberships < ActiveRecord::Migration[7.0]
  def up
    drop_table :decidim_user_group_memberships
  end

  def down
    create_table :decidim_user_group_memberships do |t|
      t.references :decidim_user, null: false, index: true, type: :integer
      t.references :decidim_user_group, null: false, index: true, type: :integer

      t.timestamps
    end

    add_index :decidim_user_group_memberships, [:decidim_user_id, :decidim_user_group_id], unique: true, name: "decidim_user_group_memberships_unique_user_and_group_ids"
    add_column :decidim_user_group_memberships, :role, :string, default: "requested"
    execute("UPDATE decidim_user_group_memberships SET role = 'creator'")
    change_column_null :decidim_user_group_memberships, :role, false
    add_index(
      :decidim_user_group_memberships,
      %w(role decidim_user_group_id),
      where: "(role = 'creator')",
      name: "decidim_group_membership_one_creator_per_group",
      unique: true
    )

    add_index :decidim_user_group_memberships, [:decidim_user_group_id, :decidim_user_id], name: "index_user_group_memberships_group_id_user_id"
  end
end
