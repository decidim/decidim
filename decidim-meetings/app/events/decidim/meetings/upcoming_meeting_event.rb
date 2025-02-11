# frozen_string_literal: true

module Decidim
  module Meetings
    class UpcomingMeetingEvent < Decidim::Events::SimpleEvent
      include Decidim::Meetings::MeetingEvent

      i18n_attributes :reminders_before_hours

      def email_intro
        (custom_message.presence || default_email_intro).to_s.html_safe
      end

      private

      def i18n_options
        {
          resource_title: translated_attribute(resource.title),
          resource_path:,
          reminders_before_hours: resource.send_reminders_before_hours,
          scope: event_name
        }
      end

      def reminder_message
        translated_attribute(resource.reminder_message_custom_content)
      end

      def default_email_intro
        I18n.t("decidim.events.meetings.upcoming_meeting.email_intro", **i18n_options)
      end

      def custom_message
        Decidim::Meetings::MeetingPresenter.new(resource).reminder_message_custom_content
      end
    end
  end
end
