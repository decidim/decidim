# frozen_string_literal: true

module Decidim
  module Proposals
    class CoauthorAcceptedInviteEvent < Decidim::Events::BaseEvent
      include Decidim::Events::NotificationEvent
      include Decidim::Core::Engine.routes.url_helpers

      def notification_title
        I18n.t("notification_title", **i18n_options).html_safe
      end

      delegate :name, to: :author, prefix: true
      delegate :name, to: :coauthor, prefix: true, allow_nil: true

      def author_path
        profile_path(author.nickname)
      end

      def coauthor_path
        profile_path(coauthor.nickname) if coauthor
      end

      def author
        resource.creator_author
      end

      def coauthor
        @coauthor ||= Decidim::User.find_by(id: extra["coauthor_id"])
      end

      def i18n_scope
        event_name
      end

      def i18n_options
        {
          scope: i18n_scope,
          coauthor_name:,
          coauthor_path:,
          author_name:,
          author_path:,
          resource_path:,
          resource_title:
        }
      end
    end
  end
end
