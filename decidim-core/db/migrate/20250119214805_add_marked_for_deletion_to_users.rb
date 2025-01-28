# frozen_string_literal: true

class AddMarkedForDeletionToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_users, :marked_for_deletion_at, :datetime

    add_index :decidim_users, :marked_for_deletion_at
  end
end
