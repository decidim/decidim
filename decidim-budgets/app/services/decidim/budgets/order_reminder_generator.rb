# frozen_string_literal: true

module Decidim
  module Budgets
    # This class is manager class which creates and updates order related reminders,
    # after reminder is generated it is send to user who have not checked out his/her/their vote.
    class OrderReminderGenerator
      attr_reader :reminders_sent

      def initialize
        @reminder_manifest = Decidim.reminders_registry.for(:orders)
        @reminders_sent = 0
      end

      # Creates reminders and updates them if they already exists.
      def generate
        Decidim::Component.where(manifest_name: "budgets").each do |component|
          send_reminders(component)
        end
      end

      def generate_for(component)
        send_reminders(component)
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
          if reminder.records.active.any?
            Decidim::Budgets::SendVoteReminderJob.perform_later(reminder)
            @reminders_sent += 1
          end
        end
      end

      def update_reminder_records(reminder, users_pending_orders)
        clean_checked_out_and_deleted_orders(reminder)
        add_pending_orders(reminder, users_pending_orders)
      end

      def clean_checked_out_and_deleted_orders(reminder)
        reminder.records.each do |record|
          if record.remindable.nil?
            record.update(state: "deleted")
          elsif record.remindable.checked_out_at.present?
            record.update(state: "completed")
          end
        end
      end

      def add_pending_orders(reminder, users_pending_orders)
        reminder_records = users_pending_orders.map { |order| Decidim::ReminderRecord.find_or_create_by(reminder: reminder, remindable: order) }
        reminder_records.each do |record|
          activity_check(record) if %w(active pending).include? record.state
        end
      end

      def activity_check(record)
        delivered_count = record.reminder.deliveries.length
        intervals = Array(reminder_manifest.settings.attributes[:reminder_times].default)
        return record.update(state: "completed") if intervals.length <= delivered_count

        state = intervals[delivered_count] < Time.current - record.remindable.created_at ? "active" : "pending"
        record.update(state: state)
      end

      def voting_enabled?(component)
        component.current_settings.votes == "enabled"
      end
    end
  end
end
