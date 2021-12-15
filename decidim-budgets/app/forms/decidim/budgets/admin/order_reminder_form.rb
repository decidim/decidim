# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class OrderReminderForm < Decidim::Form
        def reminder_amount
          @reminder_amount ||= begin
            return 0 unless voting_enabled?

            user_ids = []
            unfinished_orders.each do |order|
              next if order.user.email.blank? || order.created_at > minimum_interval_between_reminders.ago

              reminder = Decidim::Reminder.find_by(component: current_component, user: order.user)
              user_ids << order.user.id if !reminder || (reminder.deliveries.present? && reminder.deliveries.last.created_at < minimum_interval_between_reminders.ago)
            end
            user_ids.uniq.count
          end
        end

        def voting_enabled?
          current_component.current_settings.votes == "enabled"
        end

        def minimum_interval_between_reminders
          24.hours
        end

        private

        def unfinished_orders
          @unfinished_orders ||= Decidim::Budgets::Order.where(budget: budgets, checked_out_at: nil)
        end

        def budgets
          @budgets ||= Decidim::Budgets::Budget.where(component: current_component)
        end
      end
    end
  end
end
