# This migration comes from decidim (originally 20161213094244)
# frozen_string_literal: true

class AddAvatarToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_users, :avatar, :string
  end
end
