# frozen_string_literal: true

module Decidim
  module Meetings
    class UpcomingMeetingEvent < Decidim::Events::SimpleEvent
      include Decidim::Meetings::MeetingEvent

      i18n_attributes :reminders_before_hours

      def email_intro
        (custom_message.presence || default_email_intro).to_s.html_safe
      end

      def i18n_options
        {
          resource_title:,
          resource_path:,
          resource_url:,
          participatory_space_url:,
          participatory_space_title:,
          reminders_before_hours: resource.send_reminders_before_hours,
          scope: event_name
        }
      end

      private

      def reminder_message
        translated_attribute(resource.reminder_message_custom_content)
      end

      def default_email_intro
        I18n.t("decidim.events.meetings.upcoming_meeting.email_intro", **i18n_options)
      end

      def custom_message
        template = translated_attribute(resource.reminder_message_custom_content)
        interpolate_custom_message(template).html_safe
      end

      def interpolate_custom_message(template)
        title = translated_attribute(resource.title).to_s
        hours = resource.send_reminders_before_hours.to_s
        template
          .gsub("{{meeting_title}}", title)
          .gsub("{{before_hours}}", hours)
      end
    end
  end
end
