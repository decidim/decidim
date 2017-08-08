# frozen_string_literal: true

class CreateDecidimNotifications < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_notifications do |t|
      t.references :decidim_user, null: false
      t.references :decidim_followable, polymorphic: true, index: false, null: false
      t.string :notification_type, null: false
      t.timestamps
    end
  end
end
