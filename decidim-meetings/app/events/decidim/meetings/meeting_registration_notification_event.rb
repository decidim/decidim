# frozen-string_literal: true

module Decidim
  module Meetings
    class MeetingRegistrationNotificationEvent < Decidim::Events::BaseEvent
      include Decidim::Events::NotificationEvent

      def notification_title
        I18n.t("notification_title", **i18n_options).html_safe
      end

      def i18n_options
        {
          resource_title: resource_title,
          resource_url: resource_url,
          scope: event_name,
          registration_code: extra["registration_code"]
        }
      end
    end
  end
end
