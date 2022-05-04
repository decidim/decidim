# frozen_string_literal: true

module Decidim
  class ReminderRecord < ApplicationRecord
    belongs_to :reminder, foreign_key: "decidim_reminder_id", class_name: "Decidim::Reminder"
    belongs_to :remindable, foreign_type: "remindable_type", polymorphic: true, optional: true

    scope :active, -> { where(state: "active") }
    scope :pending, -> { where(state: "pending") }
    scope :completed, -> { where(state: "completed") }
    scope :deleted, -> { where(state: "deleted") }

    def active?
      state == "active"
    end

    def pending?
      state == "pending"
    end

    def completed?
      state == "completed"
    end

    def deleted?
      state == "deleted"
    end
  end
end
