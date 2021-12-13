# frozen_string_literal: true

module Decidim
  module Budgets
    class SendVoteReminderJob < ApplicationJob
      queue_as :vote_reminder

      def perform(reminder)
        ::Decidim::Budgets::VoteReminderMailer.vote_reminder(reminder).deliver_now
        ::Decidim::ReminderDelivery.create(reminder: reminder)
      end
    end
  end
end
