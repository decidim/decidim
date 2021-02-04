# frozen_string_literal: true

class RenameDecidimUserFieldsForBlockFunctionality < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_users, :suspended, :blocked
    rename_column :decidim_users, :suspended_at, :blocked_at
    rename_column :decidim_users, :suspension_id, :block_id
  end
end
