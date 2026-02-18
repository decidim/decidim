# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class OrderReminderForm < Decidim::Form
        def reminder_amount
          @reminder_amount ||= if !voting_enabled? || voting_ends_soon?
                                 0
                               else
                                 user_ids = []
                                 unfinished_orders.each do |order|
                                   reminder = Decidim::Reminder.find_by(component: current_component, user: order.user)
                                   if !reminder || (reminder.deliveries.present? && reminder.deliveries.last.created_at < minimum_interval_between_reminders.ago)
                                     user_ids << order.user.id
                                   end
                                 end
                                 user_ids.uniq.count
                               end
        end

        def voting_enabled?
          current_component.current_settings.votes == "enabled"
        end

        def voting_ends_soon?
          return false unless participatory_space.respond_to? :active_step
          return false if participatory_space.active_step.blank?
          return false unless participatory_space.active_step[:end_date]

          time_zone = current_organization.time_zone
          return false if time_zone.blank?

          end_time = participatory_space.active_step[:end_date].in_time_zone(time_zone).end_of_day

          6.hours.from_now >= end_time
        end

        def minimum_interval_between_reminders
          24.hours
        end

        private

        def minimum_time_before_first_reminder
          @minimum_time_before_first_reminder ||= begin
            reminder_manifest = Decidim.reminders_registry.for(:orders)
            if reminder_manifest.blank?
              minimum_interval_between_reminders
            else
              Array(reminder_manifest.settings.attributes[:reminder_times].default).first
            end
          end
        end

        def participatory_space
          @participatory_space ||= current_component.participatory_space
        end

        def unfinished_orders
          @unfinished_orders ||= Decidim::Budgets::Order.where(
            budget: budgets,
            checked_out_at: nil,
            created_at: Time.zone.at(0)..minimum_time_before_first_reminder.ago
          ).select do |order|
            order.user.email.present?
          end
        end

        def budgets
          @budgets ||= Decidim::Budgets::Budget.where(component: current_component)
        end
      end
    end
  end
end
