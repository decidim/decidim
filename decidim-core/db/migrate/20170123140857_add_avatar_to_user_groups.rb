# frozen_string_literal: true

class AddAvatarToUserGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_user_groups, :avatar, :string
  end
end
