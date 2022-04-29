# frozen_string_literal: true

class DropEmailsOnNotificationsFlagFromUser < ActiveRecord::Migration[5.1]
  class DecidimUser < ApplicationRecord
    self.table_name = :decidim_users
  end

  def change
    # rubocop:disable Rails/SkipsModelValidations
    DecidimUser.where(email_on_notification: true).update_all(notifications_sending_frequency: "real_time")
    # rubocop:enable Rails/SkipsModelValidations

    remove_column :decidim_users, :email_on_notification
  end
end
