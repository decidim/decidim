# This migration comes from decidim (originally 20170912082054)
# frozen_string_literal: true

class AddEmailsOnNotificationsFlagToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_users, :email_on_notification, :boolean, default: false, null: false
  end
end
