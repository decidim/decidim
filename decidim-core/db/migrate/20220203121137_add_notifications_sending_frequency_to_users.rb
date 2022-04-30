# frozen_string_literal: true

class AddNotificationsSendingFrequencyToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_users, :notifications_sending_frequency, :string, default: "none", index: true
  end
end
