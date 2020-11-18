# frozen_string_literal: true

module Decidim
  module Gamification
    class BaseEvent < Decidim::Events::SimpleEvent
      i18n_attributes :badge_name, :current_level

      delegate :url_helpers, to: "Decidim::Core::Engine.routes"

      def resource_path
        url_helpers.profile_badges_path(nickname: user.nickname)
      end

      def resource_url
        url_helpers.profile_badges_url(
          nickname: user.nickname,
          host: user.organization.host
        )
      end

      private

      def badge_name
        I18n.t "#{badge.name}.name", scope: "decidim.gamification.badges"
      end

      def badge
        @badge ||= Gamification.find_badge(extra["badge_name"])
      end

      def current_level
        extra["current_level"]
      end

      def user
        resource
      end
    end
  end
end
