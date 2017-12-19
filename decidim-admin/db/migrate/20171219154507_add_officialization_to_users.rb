# frozen_string_literal: true

class AddOfficializationToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_users, :officialized_at, :datetime
    add_column :decidim_users, :officialized_as, :jsonb
  end
end
