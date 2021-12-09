# frozen_string_literal: true

module Decidim
  class ReminderGeneratorJob < ApplicationJob
    queue_as :reminders

    def perform(manager_class)
      generator = manager_class.constantize.new
      generator.generate
    end
  end
end
