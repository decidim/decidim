# frozen_string_literal: true

module Decidim
  module Meetings
    class UpcomingMeetingEvent < Decidim::Events::SimpleEvent
      include Decidim::Meetings::MeetingEvent

      i18n_attributes :reminders_before_hours

      def notification_title
        (strip_tags(reminder_message).presence || default_notification_title).to_s.html_safe
      end

      private

      def i18n_options
        {
          resource_title: translated_attribute(resource.title),
          resource_path:,
          reminders_before_hours: resource.send_reminders_before_hours
        }
      end

      def reminder_message
        puts "reminder_message: #{translated_attribute(resource.reminder_message_custom_content)}"
        translated_attribute(resource.reminder_message_custom_content)
      end

      def default_notification_title
        I18n.t("decidim.events.meetings.upcoming_meeting.notification_title", **i18n_options)
      end
    end
  end
end
