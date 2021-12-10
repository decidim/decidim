# frozen_string_literal: true

module Decidim
  module Budgets
    class VoteReminderGenerator
      def initialize
        @reminder_manifest = Decidim.reminders_registry.for(:orders)
      end

      def generate
        Decidim::Component.where(manifest_name: "budgets").each do |component|
          send_reminders(component)
        end
      end

      private

      attr_reader :reminder_manifest

      def send_reminders(component)
        budgets = Decidim::Budgets::Budget.where(component: component)
        pending_orders = Decidim::Budgets::Order.where(budget: budgets, checked_out_at: nil)
        users = Decidim::User.where(id: pending_orders.pluck(:decidim_user_id).uniq)
        users.each do |user|
          reminder = Decidim::Reminder.find_or_create_by(user: user, component: component)
          users_pending_orders = pending_orders.where(user: user)
          update_reminder_records(reminder, users_pending_orders)
          Decidim::Budgets::SendVoteReminderJob.perform_later(reminder) if reminder.records.any?
        end
      end

      def update_reminder_records(reminder, users_pending_orders)
        clean_checked_out_and_deleted_orders(reminder)
        add_pending_orders(reminder, users_pending_orders)
      end

      def clean_checked_out_and_deleted_orders(reminder)
        reminder.records.each do |record|
          if record.remindable.nil?
            reminder.records.delete(record)
          elsif record.remindable.checked_out_at.present?
            record.update(reminder: nil)
          end
        end
      end

      def add_pending_orders(reminder, users_pending_orders)
        reminder_records = users_pending_orders.map { |order| Decidim::ReminderRecord.find_or_create_by(reminder: reminder, remindable: order) }
        reminder_records.each do |record|
          reminder.records.push(record) if reminder.records.exclude?(record) && time_to_remind?(reminder, record.remindable)
        end
      end

      def time_to_remind?(reminder, order)
        delivered_count = reminder.deliveries.length
        intervals = Array(reminder_manifest.settings.attributes[:reminder_times].default)
        return false if intervals.length <= delivered_count

        intervals[delivered_count] < Time.current - order.created_at
      end

      def voting_enabled?(component)
        component.current_settings.votes == "enabled"
      end
    end
  end
end
