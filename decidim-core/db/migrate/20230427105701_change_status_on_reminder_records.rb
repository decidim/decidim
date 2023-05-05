# frozen_string_literal: true

class ChangeStatusOnReminderRecords < ActiveRecord::Migration[6.1]
  class ReminderRecord < ApplicationRecord
    self.table_name = :decidim_reminder_records
    STATES = %w(active pending completed deleted).freeze
  end

  def up
    rename_column :decidim_reminder_records, :state, :old_state
    add_column :decidim_reminder_records, :state, :integer, default: 0, null: false

    ReminderRecord.reset_column_information

    ReminderRecord.find_each do |reminder|
      amendment.update(state: ReminderRecord::STATES.index(reminder.old_state))
    end

    remove_column :decidim_reminder_records, :old_state
    ReminderRecord.reset_column_information
  end

  def down
    rename_column :decidim_reminder_records, :state, :old_state
    add_column :decidim_reminder_records, :state, :string, default: "draft", null: false
    ReminderRecord.reset_column_information
    ReminderRecord.find_each do |amendment|
      amendment.update(state: ReminderRecord::STATES[amendment.old_state])
    end
    remove_column :decidim_reminder_records, :old_state
    ReminderRecord.reset_column_information
  end
end
