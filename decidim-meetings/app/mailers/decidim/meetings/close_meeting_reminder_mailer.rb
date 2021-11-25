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

      def first_notification(meeting, user)
        notify(meeting, user)
      end

      def reminder_notification(meeting, user)
        notify(meeting, user)
      end

      private

      def notify(meeting, user)
        with_user(user) do
          @user = user
          @meeting = meeting
          @organization = user.organization
          mail(
            to: user.email,
            subject: I18n.t(
              "decidim.meetings.close_meeting_reminder_mailer.first_notification.subject",
              organization_name: @organization.name
            ),
            template_name: "first_notification"
          )
        end
      end
    end
  end
end
