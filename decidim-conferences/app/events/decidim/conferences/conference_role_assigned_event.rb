# frozen-string_literal: true

module Decidim
  module Conferences
    class ConferenceRoleAssignedEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::NotificationEvent
      include Decidim::Events::AuthorEvent

      def notification_title
        I18n.t("notification_title", i18n_options).html_safe
      end

      def i18n_role
        I18n.t(extra["role"], "decidim.admin.models.conference_user_role.roles", default: extra["role"])
      end

      def i18n_options
        {
          resource_path: resource_path,
          resource_title: resource_title,
          resource_url: resource_url,
          scope: event_name,
          participatory_space_title: participatory_space_title,
          participatory_space_url: participatory_space_url,
          role: i18n_role
        }
      end
    end
  end
end
