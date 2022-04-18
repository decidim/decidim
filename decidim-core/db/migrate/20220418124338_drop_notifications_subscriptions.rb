# frozen_string_literal: true

class DropNotificationsSubscriptions < ActiveRecord::Migration[6.0]
  def change
    drop_table :decidim_notifications_subscriptions
  end
end
