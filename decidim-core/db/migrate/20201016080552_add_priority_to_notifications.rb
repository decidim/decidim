# frozen_string_literal: true

class AddPriorityToNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_notifications, :priority, :integer, null: false, default: 0
  end
end
