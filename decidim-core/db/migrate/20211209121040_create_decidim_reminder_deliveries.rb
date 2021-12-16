# frozen_string_literal: true

class CreateDecidimReminderDeliveries < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_reminder_deliveries do |t|
      t.belongs_to :decidim_reminder, index: true, foreign_key: true
      t.timestamps
    end
  end
end
