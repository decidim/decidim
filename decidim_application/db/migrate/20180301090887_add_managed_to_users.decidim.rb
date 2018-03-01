# This migration comes from decidim (originally 20170720135441)
# frozen_string_literal: true

class AddManagedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_users, :managed, :boolean, null: false, default: false
  end
end
