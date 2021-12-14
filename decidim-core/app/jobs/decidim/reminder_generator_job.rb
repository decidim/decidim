# frozen_string_literal: true

module Decidim
  class ReminderGeneratorJob < ApplicationJob
    queue_as :reminders

    def perform(manager_class_name)
      generator = manager_class_name.constantize.new
      generator.generate
    end
  end
end
