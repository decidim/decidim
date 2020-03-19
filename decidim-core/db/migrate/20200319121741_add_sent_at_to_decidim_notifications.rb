# frozen_string_literal: true

class AddSentAtToDecidimNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_notifications, :sent_at, :datetime
  end
end
