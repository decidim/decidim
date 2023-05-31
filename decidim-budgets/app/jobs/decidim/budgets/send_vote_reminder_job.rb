# frozen_string_literal: true

module Decidim
  module Budgets
    class SendVoteReminderJob < ApplicationJob
      queue_as :vote_reminder

      def perform(reminder)
        return if reminder.records.active.blank?

        ::Decidim::ReminderDelivery.create(reminder:)
        ::Decidim::Budgets::VoteReminderMailer.vote_reminder(reminder).deliver_now
      end
    end
  end
end
