# frozen_string_literal: true

class AddComponentNotificationSettingsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_users, :component_notification_settings, :jsonb, default: {}
  end
end
