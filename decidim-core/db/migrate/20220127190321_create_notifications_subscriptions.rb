# frozen_string_literal: true

class CreateNotificationsSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_notifications_subscriptions do |t|
      t.belongs_to :decidim_user, index: true, foreign_key: true, null: false
      t.string :endpoint
      t.string :p256dh
      t.string :auth

      t.timestamps
    end
  end
end
