# frozen_string_literal: true

module Decidim
  class ReminderGeneratorJob < ApplicationJob
    queue_as :reminders

    def perform(reminder_manifest, organization)
      return unless organization

      generator = manifest.manager_class.new(reminder_manifest, organization)
      reminders = generator.generate

      reminders.each do |reminder|
        manifest.delivery_class.perform_later(reminder)
      end
    end
  end
end
