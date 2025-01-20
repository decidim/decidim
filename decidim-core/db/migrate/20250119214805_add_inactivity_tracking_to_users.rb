# frozen_string_literal: true

class AddInactivityTrackingToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_users, :last_inactivity_notice_sent_at, :datetime
    add_column :decidim_users, :removal_date, :datetime

    add_index :decidim_users, :last_inactivity_notice_sent_at
    add_index :decidim_users, :removal_date
  end
end
