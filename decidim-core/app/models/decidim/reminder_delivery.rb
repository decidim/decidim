# frozen_string_literal: true

module Decidim
  class ReminderDelivery < ApplicationRecord
    self.table_name = "decidim_reminder_deliveries"
    belongs_to :reminder, foreign_key: "decidim_reminder_id", class_name: "Decidim::Reminder"
  end
end
