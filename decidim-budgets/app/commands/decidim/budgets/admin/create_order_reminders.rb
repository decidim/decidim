# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when admin sends vote reminders.
      class CreateOrderReminders < Rectify::Command
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
                if record.remindable.created_at > minimum_time_between_reminders ||
                   (reminder.deliveries.present? && reminder.deliveries.last.created_at > minimum_time_between_reminders)
                  "pending"
                else
                  "active"
                end
              end
              record.save if record.changed?
            end
          end
        end

        def minimum_time_between_reminders
          form.minimum_interval_between_reminders.ago
        end

        def generator
          @generator ||= Decidim::Budgets::OrderReminderGenerator.new
        end

        def current_component
          form.current_component
        end

        def voting_enabled?
          form.voting_enabled?
        end

        def voting_ends_soon?
          form.voting_ends_soon?
        end
      end
    end
  end
end
