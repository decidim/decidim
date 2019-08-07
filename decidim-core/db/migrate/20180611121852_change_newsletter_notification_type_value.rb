# frozen_string_literal: true

class ChangeNewsletterNotificationTypeValue < ActiveRecord::Migration[5.2]
  class User < ApplicationRecord
    self.table_name = :decidim_users
  end

  def up
    add_column :decidim_users, :newsletter_token, :string, default: ""
    add_column :decidim_users, :newsletter_notifications_at, :datetime
    User.reset_column_information
    User.where(newsletter_notifications: true).update(newsletter_notifications_at: Time.zone.parse("2018-05-24 00:00 +02:00"))
    remove_column :decidim_users, :newsletter_notifications
  end

  def down
    add_column :decidim_users, :newsletter_notifications, :boolean
    User.reset_column_information
    User.where.not(newsletter_notifications_at: nil).update(newsletter_notifications: true)
    remove_column :decidim_users, :newsletter_notifications_at
    remove_column :decidim_users, :newsletter_token
  end
end
