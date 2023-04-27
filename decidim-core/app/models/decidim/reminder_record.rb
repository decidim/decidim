# frozen_string_literal: true

module Decidim
  class ReminderRecord < ApplicationRecord
    belongs_to :reminder, foreign_key: "decidim_reminder_id", class_name: "Decidim::Reminder"
    belongs_to :remindable, foreign_type: "remindable_type", polymorphic: true, optional: true

    enum state: { active: "active", pending: "pending", completed: "completed", deleted: "deleted" }
  end
end
