# frozen_string_literal: true

module Decidim
  class ReminderDelivery < ApplicationRecord
    belongs_to :reminder, foreign_key: "decidim_reminder_id", class_name: "Decidim::Reminder"
  end
end
