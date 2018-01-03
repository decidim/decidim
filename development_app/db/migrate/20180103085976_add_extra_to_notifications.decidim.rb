# This migration comes from decidim (originally 20170906091718)
# frozen_string_literal: true

class AddExtraToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_notifications, :extra, :jsonb
  end
end
