# frozen_string_literal: true

module Decidim
  module Budgets
    class VoteReminderGenerator
      def initialize
        @manifest = Decidim.reminders_registry.for(:orders)
      end

      def generate
        Decidim::Component.where(manifest_name: "budgets").each do |component|
          send_reminders(component)
        end
      end

      private

      attr_reader :manifest

      def send_reminders(component)
        budgets = Decidim::Budgets::Budget.where(component: component)
        pending_orders = Decidim::Budgets::Order.where(budget: budgets, checked_out_at: nil)
        users = Decidim::User.where(id: pending_orders.pluck(:decidim_user_id).uniq)
        users.each do |user|
          reminder = Decidim::Reminder.first_or_create(user: user, component: component)
          users_pending_orders = pending_orders.where(user: user)
          add_reminder_records(reminder, users_pending_orders)
          if time_to_remind?(reminder, users_pending_orders)
            ::Decidim::ReminderDelivery.create(reminder: reminder)
            ::Decidim::Budgets::SendVoteReminderJob.perform_now(reminder)
          end
        end
      end

      def add_reminder_records(reminder, users_pending_orders)
        reminder_records = users_pending_orders.map { |order| Decidim::ReminderRecord.first_or_create(reminder: reminder, remindable: order) }
        reminder.records.push(*reminder_records)
      end

      def time_to_remind?(reminder, users_pending_orders)
        delivered_count = reminder.deliveries.length
        intervals = Array(manifest.settings.attributes[:reminder_times].default)
        return false if intervals.length <= delivered_count

        intervals[delivered_count] < Time.current - users_pending_orders.last.created_at
      end

      def voting_enabled?(component)
        component.current_settings.votes == "enabled"
      end
    end
  end
end
