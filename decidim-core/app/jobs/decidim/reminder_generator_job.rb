# frozen_string_literal: true

module Decidim
  class ReminderGeneratorJob < ApplicationJob
    queue_as :reminders

    def perform(generator_class_name)
      generator = generator_class_name.constantize.new
      generator.generate
    end
  end
end
