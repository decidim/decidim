# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when an admin sends vote reminders.
      class CreateOrderReminders < Decidim::Command
        delegate :current_component, :voting_enabled?, :voting_ends_soon?, :minimum_interval_between_reminders, to: :form

        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless voting_enabled?
          return broadcast(:invalid) if voting_ends_soon?

          generator.generate_for(current_component, &alternative_refresh_state)

          broadcast(:ok, generator.reminder_jobs_queued)
        end

        private

        attr_reader :form

        def alternative_refresh_state
          proc do |reminder|
            reminder.records.each do |record|
              next if %w(active pending).exclude? record.state

              record.state = begin
                if record.remindable.created_at > minimum_interval_between_reminders.ago ||
                   (reminder.deliveries.present? && reminder.deliveries.last.created_at > minimum_interval_between_reminders.ago)
                  "pending"
                else
                  "active"
                end
              end
              record.save if record.changed?
            end
          end
        end

        def generator
          @generator ||= Decidim::Budgets::OrderReminderGenerator.new
        end
      end
    end
  end
end
