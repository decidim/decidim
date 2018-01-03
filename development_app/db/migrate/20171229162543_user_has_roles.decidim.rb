# This migration comes from decidim (originally 20160920141151)
# frozen_string_literal: true

class UserHasRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_users, :roles, :string, array: true, default: []
  end
end
