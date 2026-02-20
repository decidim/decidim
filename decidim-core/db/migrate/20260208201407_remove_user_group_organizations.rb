# frozen_string_literal: true

class RemoveUserGroupOrganizations < ActiveRecord::Migration[7.0]
  def up
    remove_column :decidim_organizations, :user_groups_enabled
  end

  def down
    add_column :decidim_organizations, :user_groups_enabled, :boolean, default: false, null: false
  end
end
