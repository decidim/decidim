# frozen_string_literal: true

class IndexForeignKeysInDecidimNotifications < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_notifications, :decidim_resource_id
  end
end
