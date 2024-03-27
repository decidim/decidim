# frozen-string_literal: true

module Decidim
  module Conferences
    class ConferenceRegistrationNotificationEvent < Decidim::Events::BaseEvent
      include Decidim::Events::NotificationEvent
      include Decidim::SanitizeHelper

      def notification_title
        I18n.t("notification_title", **i18n_options).html_safe
      end

      def i18n_options
        {
          resource_title: resource_title,
          resource_path: resource_path,
          resource_url: resource_url,
          scope: event_name
        }
      end

      def resource_title
        return unless resource

        title = decidim_sanitize_translated(resource.title)

        Decidim::ContentProcessor.render_without_format(title, links: false).html_safe
      end
    end
  end
end
