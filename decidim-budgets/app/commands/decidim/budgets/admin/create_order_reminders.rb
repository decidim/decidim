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

          generate

          broadcast(:ok, generator.reminders_sent)
        end

        private

        attr_reader :form

        def generate
          generator.generate_for(current_component)
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
      end
    end
  end
end
