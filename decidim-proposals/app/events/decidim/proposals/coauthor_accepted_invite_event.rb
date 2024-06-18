# frozen_string_literal: true

module Decidim
  module Proposals
    class CoauthorAcceptedInviteEvent < Decidim::Events::BaseEvent
      include Decidim::Events::NotificationEvent
      include Decidim::Core::Engine.routes.url_helpers

      def notification_title
        I18n.t("notification_title", **i18n_options).html_safe
      end

      def user_path
        profile_path(user.nickname)
      end

      delegate :name, to: :user, prefix: true

      delegate :name, to: :author, prefix: true

      def author_path
        profile_path(author.nickname)
      end

      def author
        resource.creator_author
      end

      def i18n_scope
        event_name
      end

      def i18n_options
        {
          scope: i18n_scope,
          user_name:,
          user_path:,
          author_name:,
          author_path:,
          resource_path:,
          resource_title:
        }
      end
    end
  end
end
