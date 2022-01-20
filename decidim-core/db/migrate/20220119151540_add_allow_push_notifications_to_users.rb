# frozen_string_literal: true

class AddAllowPushNotificationsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_users, :allow_push_notifications, :boolean, default: false
  end
end
