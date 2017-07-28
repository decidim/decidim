# frozen_string_literal: true

class AddOrganizationToUserGroups < ActiveRecord::Migration[5.0]
  class UserGroup < ApplicationRecord
    self.table_name = :decidim_user_groups
  end

  def change
    add_column :decidim_user_groups, :decidim_organization_id, :integer

    UserGroup.find_each do |user_group|
      execute <<~SQL.squish
        UPDATE decidim_user_groups
        SET decidim_organization_id = (
          SELECT MIN(u.decidim_organization_id)
          FROM decidim_users u
          INNER JOIN decidim_user_group_memberships m
          ON u.id = m.decidim_user_id
          WHERE m.decidim_user_group_id = #{user_group.id}
        )
        WHERE id = #{user_group.id}
      SQL
    end

    change_column :decidim_user_groups, :decidim_organization_id, :integer, null: false
  end
end
