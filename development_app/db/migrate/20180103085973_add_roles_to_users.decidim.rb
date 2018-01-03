# This migration comes from decidim (originally 20170727125445)
# frozen_string_literal: true

class AddRolesToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_users, :roles, :string, array: true, default: []
  end
end
