# frozen_string_literal: true

module Decidim
  module Meetings
    # A custom mailer for sending notifications for overdue meetings
    class CloseMeetingReminderMailer < Decidim::ApplicationMailer
      def first_notification(meeting, user)
        notify(meeting, user)
      end

      def reminder_notification(meeting, user)
        notify(meeting, user)
      end

      private

      def notify(meeting, user)
        @user = user
        @meeting = meeting
        @locale = user.locale
        @organization = user.organization
        mail(
          to: user.email,
          subject: I18n.t(
            "decidim.meetings.close_meeting_reminder_mailer.first_notification.subject",
            organization_name: @organization.name
          )
        )
      end
    end
  end
end
