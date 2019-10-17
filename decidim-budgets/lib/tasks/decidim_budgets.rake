# frozen_string_literal: true

namespace :decidim do
  namespace :budgets do
    desc "Setup environment so that only decidim migrations are installed."
    task reminder: :environment do
      pending_orders = Decidim::Budgets::Order.where(checked_out_at: nil).where("updated_at < ?", 1.day.ago)

      still_open_pending_orders = pending_orders.select { |order| order.component.current_settings.votes_enabled? == true }

      return if still_open_pending_orders.empty?

      notify_users(still_open_pending_orders)
    end
  end
end

def notify_users(orders)
  orders.each do |order|
    Decidim::EventsManager.publish(
      event: "decidim.events.budgets.reminder_order",
      event_class: Decidim::Budgets::ReminderOrderEvent,
      resource: order.component,
      affected_users: [order.user]
    )
  end
end
