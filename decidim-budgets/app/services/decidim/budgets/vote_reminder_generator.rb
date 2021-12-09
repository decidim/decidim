# frozen_string_literal: true

module Decidim
  class VoteReminderGenerator
    def initialize(manifest, organization)
      @organization = organization
      @manifest = manifest
    end

    def generate
      reminders = []
      Decidim::Component.where(organization: @organization, manifest_name: "budgets").each do |component|
        reminders.push(*create_reminders(component))
      end

      Decidim::ReminderJob.perform_later(reminders)
    end

    private

    def create_reminders(component)
      return unless voting_enabled?

      reminders = []
      budgets = Decidim::Budgets::Budget.where(component: component)
      orders = Decidim::Budgets::Order.where(budget: budgets, checked_out_at: nil)

      orders.each do |order|
        next unless order.user
        next if order.user.email.blank?

        reminder = ::Decidim::Budgets::VoteReminder.find_or_create_by!(user: order.user, component: @component)
        reminder.orders << order
        reminders << reminder if reminders.select { |r| r.user == order.user && r.component == @component }.blank?
      end

      clean_checked_out_orders(reminders)

      reminders
    end
  end
end
