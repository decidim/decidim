# frozen-string_literal: true

module Decidim
  module Admin
    class UserOfficializedEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_subject
        I18n.t(
          "decidim.admin.events.user_officialized_event.email_subject",
          profile_path: official_user.profile_path,
          nickname: official_user.nickname,
          name: official_user.name
        )
      end

      def email_intro
        I18n.t(
          "decidim.admin.events.user_officialized_event.email_intro",
          profile_path: official_user.profile_path,
          nickname: official_user.nickname,
          name: official_user.name
        )
      end

      def email_outro
        I18n.t(
          "decidim.admin.events.user_officialized_event.email_outro",
          profile_path: official_user.profile_path,
          nickname: official_user.nickname,
          name: official_user.name
        )
      end

      def notification_title
        I18n.t(
          "decidim.admin.events.user_officialized_event.notification_title",
          profile_path: official_user.profile_path,
          nickname: official_user.nickname,
          name: official_user.name
        ).html_safe
      end

      private

      def official_user
        @official_user ||= Decidim::UserPresenter.new(resource)
      end
    end
  end
end
