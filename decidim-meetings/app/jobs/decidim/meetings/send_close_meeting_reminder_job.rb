# frozen_string_literal: true

module Decidim
  module Meetings
    class SendCloseMeetingReminderJob < ApplicationJob
      queue_as :close_meeting_reminder

      def perform(record)
        return if record.remindable.closed?

        ::Decidim::ReminderDelivery.create(reminder: record.reminder)
        ::Decidim::Meetings::CloseMeetingReminderMailer.close_meeting_reminder(record).deliver_now
        record.update(state: "completed")
      end
    end
  end
end
