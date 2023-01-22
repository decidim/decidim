# frozen_string_literal: true

module Decidim
  class ReminderRecord < ApplicationRecord
    include EnumerableAttribute

    belongs_to :reminder, foreign_key: "decidim_reminder_id", class_name: "Decidim::Reminder"
    belongs_to :remindable, foreign_type: "remindable_type", polymorphic: true, optional: true

    enum_fields :state, %w(active pending completed deleted)
  end
end
