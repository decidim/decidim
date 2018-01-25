# frozen-string_literal: true

module Decidim
  module Debates
    # Notifies users about a new debate. Accepts a Hash in the `extra`
    # field with the key `:type`, which can hold two different values:
    #
    # "user" - The event is being sent to the followers of the debate
    #          author
    # "participatory_space" - The event is being sento to the followers
    #                         of the event's participatory space.
    class CreateDebateEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_subject
        I18n.t(
          "email_subject",
          scope: i18n_scope,
          space_title: space_title,
          author_nickname: author.nickname
        )
      end

      def email_intro
        I18n.t(
          "email_intro",
          scope: i18n_scope,
          resource_title: resource_title,
          space_title: space_title,
          author_nickname: author.nickname,
          author_name: author.name
        )
      end

      def email_outro
        I18n.t(
          "email_outro",
          scope: i18n_scope,
          space_title: space_title,
          author_nickname: author.nickname
        )
      end

      def notification_title
        I18n.t(
          "notification_title",
          scope: i18n_scope,
          resource_title: resource_title,
          resource_path: resource_path,
          space_title: space_title,
          space_path: space_path,
          author_nickname: author.nickname,
          author_name: author.name,
          author_path: author.profile_path
        ).html_safe
      end

      private

      def space
        @space ||= resource.participatory_space
      end

      def space_path
        Decidim::ResourceLocatorPresenter.new(space).path
      end

      def space_title
        space.title.is_a?(Hash) ? space.title[I18n.locale.to_s] : space.title
      end

      def author
        @author ||= Decidim::UserPresenter.new(resource.author)
      end

      def i18n_scope
        @scope ||= if extra[:type].to_s == "user"
                     "decidim.debates.events.create_debate_event.user_followers"
                   else
                     "decidim.debates.events.create_debate_event.space_followers"
                   end
      end
    end
  end
end
