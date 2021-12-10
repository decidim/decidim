# frozen_string_literal: true

module Decidim
  class ReminderRecord < ApplicationRecord
    self.table_name = "decidim_reminder_records"
    belongs_to :reminder, foreign_key: "decidim_reminder_id", class_name: "Decidim::Reminder", optional: true
    belongs_to :remindable, foreign_type: "remindable_type", polymorphic: true
  end
end
