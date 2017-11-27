# This migration comes from decidim (originally 20170203150545)
# frozen_string_literal: true

class AddNewsletterNotificationsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_users, :newsletter_notifications, :boolean, null: false, default: false
  end
end
