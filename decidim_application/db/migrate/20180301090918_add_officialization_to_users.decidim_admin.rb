# This migration comes from decidim_admin (originally 20171219154507)
# frozen_string_literal: true

class AddOfficializationToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_users, :officialized_at, :datetime
    add_column :decidim_users, :officialized_as, :jsonb

    add_index :decidim_users, :officialized_at
  end
end
