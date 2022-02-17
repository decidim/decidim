# frozen_string_literal: true

module Decidim
  module Meetings
    # A custom mailer for sending notifications for overdue meetings
    class CloseMeetingReminderMailer < Decidim::ApplicationMailer
      include Decidim::TranslationsHelper
      include ActionView::Helpers::SanitizeHelper
      include Decidim::ApplicationHelper

      helper Decidim::ResourceHelper
      helper Decidim::TranslationsHelper
      helper Decidim::ApplicationHelper

      helper_method :routes

      # Send the user an email reminder to close the meetings
      #
      # record - the reminder record specific to a past meeting.
      def close_meeting_reminder(record)
        @reminder = record.reminder
        @user = record.reminder.user
        with_user(@user) do
          @meeting = record.remindable
          @organization = @user.organization
          mail(
            to: @user.email,
            subject: I18n.t(
              "decidim.meetings.close_meeting_reminder_mailer.close_meeting_reminder.subject",
              organization_name: @organization.name
            )
          )
        end
      end

      private

      def routes
        @routes ||= Decidim::EngineRouter.main_proxy(@reminder.component)
      end
    end
  end
end
