# frozen_string_literal: true

module Decidim
  module Budgets
    # This class is the generator class which creates and updates order related reminders,
    # after reminder is generated it is send to user who have not checked out his/her/their vote.
    class OrderReminderGenerator
      attr_reader :reminder_jobs_queued

      def initialize
        @reminder_manifest = Decidim.reminders_registry.for(:orders)
        @reminder_jobs_queued = 0
      end

      # Creates reminders and updates them if they already exists.
      def generate
        Decidim::Component.where(manifest_name: "budgets").each do |component|
          next if component.current_settings.votes != "enabled"

          send_reminders(component)
        end
      end

      def generate_for(component, &block)
        @alternative_refresh_state = block
        send_reminders(component)
      end

      private

      attr_reader :reminder_manifest

      def send_reminders(component)
        budgets = Decidim::Budgets::Budget.where(component:)
        pending_orders = Decidim::Budgets::Order.where(budget: budgets, checked_out_at: nil)
        users = Decidim::User.where(id: pending_orders.pluck(:decidim_user_id).uniq)
        users.each do |user|
          reminder = Decidim::Reminder.find_or_create_by(user:, component:)
          users_pending_orders = pending_orders.where(user:)
          update_reminder_records(reminder, users_pending_orders)
          if reminder.records.active.any?
            Decidim::Budgets::SendVoteReminderJob.perform_later(reminder)
            @reminder_jobs_queued += 1
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
        reminder.records << users_pending_orders.map { |order| Decidim::ReminderRecord.find_or_create_by(reminder:, remindable: order) }
        return @alternative_refresh_state.call(reminder) if @alternative_refresh_state.present?

        reminder.records.each do |record|
          refresh_state(record, reminder.deliveries.length) if %w(active pending).include? record.state
        end
      end

      def refresh_state(record, delivered_count)
        intervals = Array(reminder_manifest.settings.attributes[:reminder_times].default)
        return record.update(state: "pending") if delivered_count >= intervals.length

        record.state = intervals[delivered_count].ago > record.remindable.created_at ? "active" : "pending"
        record.save if record.changed?
      end

      def voting_enabled?(component)
        component.current_settings.votes == "enabled"
      end
    end
  end
end
