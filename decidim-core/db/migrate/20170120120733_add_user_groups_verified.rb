# frozen_string_literal: true

class AddUserGroupsVerified < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_user_groups, :verified, :boolean, default: false
  end
end
