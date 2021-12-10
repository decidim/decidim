class CreateDecidimReminderRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_reminder_records do |t|
      t.belongs_to :decidim_reminder, foreign_key: true
      t.belongs_to :remindable, polymorphic: true, null: false, index: { name: "index_decidim_reminder_records_remindable" }
    end
  end
end
