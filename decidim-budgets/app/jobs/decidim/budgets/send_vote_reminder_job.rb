# frozen_string_literal: true

module Decidim
  module Budgets
    class VoteReminderDeliveryJob < ApplicationJob
      queue_as :vote_reminder

      def perform(reminder)
        order_ids = reminder.orders.pluck(:id)
        return if order_ids.blank?

        ::Decidim::Budgets::VoteReminderMailer.vote_reminder(reminder.user, order_ids).deliver_now
      end
    end
  end
end
