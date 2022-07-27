# frozen-string_literal: true

module Decidim
  module Initiatives
    class CreateInitiativeEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_subject
        I18n.t(
          "decidim.initiatives.events.create_initiative_event.email_subject",
          resource_title:,
          author_nickname: author.nickname,
          author_name: author.name
        )
      end

      def email_intro
        I18n.t(
          "decidim.initiatives.events.create_initiative_event.email_intro",
          resource_title:,
          author_nickname: author.nickname,
          author_name: author.name
        )
      end

      def email_outro
        I18n.t(
          "decidim.initiatives.events.create_initiative_event.email_outro",
          resource_title:,
          author_nickname: author.nickname,
          author_name: author.name
        )
      end

      def notification_title
        I18n.t(
          "decidim.initiatives.events.create_initiative_event.notification_title",
          resource_title:,
          resource_path:,
          author_nickname: author.nickname,
          author_name: author.name,
          author_path: author.profile_path
        ).html_safe
      end

      private

      def author
        @author ||= Decidim::UserPresenter.new(resource.author)
      end
    end
  end
end
