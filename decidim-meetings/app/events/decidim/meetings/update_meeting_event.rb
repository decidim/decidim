# frozen_string_literal: true

module Decidim
  module Meetings
    class UpdateMeetingEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_subject
        I18n.t("decidim.meetings.events.update_meeting_event.email_subject", resource_title: resource_title)
      end

      def email_intro
        I18n.t("decidim.meetings.events.update_meeting_event.email_intro", resource_title: resource_title)
      end

      def email_outro
        I18n.t("decidim.meetings.events.update_meeting_event.email_outro", resource_title: resource_title)
      end
    end
  end
end
