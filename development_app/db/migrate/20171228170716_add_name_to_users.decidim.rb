# This migration comes from decidim (originally 20161010085443)
# frozen_string_literal: true

class AddNameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_users, :name, :string, null: false
  end
end
