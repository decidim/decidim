# frozen_string_literal: true

class AddInitiativeNotificationDates < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_initiatives,
               :first_progress_notification_at, :datetime, index: true

    add_column :decidim_initiatives,
               :second_progress_notification_at, :datetime, index: true
  end
end
