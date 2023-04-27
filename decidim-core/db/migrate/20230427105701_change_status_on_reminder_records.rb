# frozen_string_literal: true

class ChangeStatusOnReminderRecords < ActiveRecord::Migration[6.1]
  def up
    rename_column :decidim_reminder_records, :state, :old_state
    add_column :decidim_reminder_records, :state, :integer, default: 0, null: false

    Decidim::ReminderRecord.reset_column_information

    Decidim::ReminderRecord.find_each do |reminder|
      amendment.update(state: Decidim::ReminderRecord::STATES.index(reminder.old_state))
    end

    remove_column :decidim_reminder_records, :old_state
    Decidim::ReminderRecord.reset_column_information
  end

  def down
    rename_column :decidim_reminder_records, :state, :old_state
    add_column :decidim_reminder_records, :state, :string, default: "draft", null: false
    Decidim::ReminderRecord.reset_column_information
    Decidim::ReminderRecord.find_each do |amendment|
      amendment.update(state: Decidim::ReminderRecord::STATES[amendment.old_state])
    end
    remove_column :decidim_reminder_records, :old_state
    Decidim::ReminderRecord.reset_column_information
  end
end
