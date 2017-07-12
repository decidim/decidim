# This migration comes from decidim (originally 20170608142521)
# frozen_string_literal: true

class AddOrganizationToUserGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_user_groups, :decidim_organization_id, :integer

    Decidim::UserGroup.includes(:users).find_each do |user_group|
      user_group.organization = user_group.users.first.organization
      user_group.save!(validate: false)
    end

    change_column :decidim_user_groups, :decidim_organization_id, :integer, null: false
  end
end
