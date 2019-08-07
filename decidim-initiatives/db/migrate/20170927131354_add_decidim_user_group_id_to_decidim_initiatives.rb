# frozen_string_literal: true

class AddDecidimUserGroupIdToDecidimInitiatives < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_initiatives,
               :decidim_user_group_id, :integer, index: true
  end
end
