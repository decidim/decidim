# frozen_string_literal: true

module Decidim
  class ReminderRecord < ApplicationRecord
    STATES = { active: 0, pending: 10, completed: 20, deleted: -1 }.freeze

    belongs_to :reminder, foreign_key: "decidim_reminder_id", class_name: "Decidim::Reminder"
    belongs_to :remindable, foreign_type: "remindable_type", polymorphic: true, optional: true

    enum :state, STATES
  end
end
