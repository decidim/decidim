# frozen_string_literal: true

class AddBadgeSwitchToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_organizations, :badges_enabled, :boolean, null: false, default: false
    execute "UPDATE decidim_organizations set badges_enabled = true"
  end
end
