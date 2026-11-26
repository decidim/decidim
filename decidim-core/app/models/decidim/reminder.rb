# frozen_string_literal: true

module Decidim
  class Reminder < ApplicationRecord
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User", inverse_of: :reminders
    belongs_to :component, foreign_key: "decidim_component_id", class_name: "Decidim::Component"
    has_many :records, foreign_key: "decidim_reminder_id", class_name: "Decidim::ReminderRecord", inverse_of: :reminder, dependent: :destroy
    has_many :deliveries, foreign_key: "decidim_reminder_id", class_name: "Decidim::ReminderDelivery", inverse_of: :reminder, dependent: :destroy
  end
end
