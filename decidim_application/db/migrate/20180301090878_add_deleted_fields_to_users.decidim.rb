# This migration comes from decidim (originally 20170605140421)
# frozen_string_literal: true

class AddDeletedFieldsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_users, :delete_reason, :text
    add_column :decidim_users, :deleted_at, :datetime
  end
end
