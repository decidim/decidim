# frozen_string_literal: true

class AddCommentsAndRepliesNotificationsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_users, :comments_notifications, :boolean, null: false, default: false
    add_column :decidim_users, :replies_notifications, :boolean, null: false, default: false
  end
end
