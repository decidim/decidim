# frozen-string_literal: true

module Decidim
  module Comments
    class UserMentionedEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_subject
        I18n.t(
          "decidim.comments.events.user_mentioned.email_subject",
          resource_title: resource_title,
          resource_url: resource_locator.url(url_params)
        )
      end

      def email_intro
        I18n.t("decidim.comments.events.user_mentioned.email_intro")
      end

      def email_outro
        I18n.t(
          "decidim.comments.events.user_mentioned.email_outro",
          resource_title: resource_title
        )
      end

      def notification_title
        I18n.t(
          "decidim.comments.events.user_mentioned.notification_title",
          resource_title: resource_title,
          resource_path: resource_locator.path(url_params),
          author_nickname: author.nickname,
          author_name: author.name,
          author_path: author.profile_path
        ).html_safe
      end

      private

      def author
        @author ||= Decidim::UserPresenter.new(comment.author)
      end

      def comment
        @comment ||= Decidim::Comments::Comment.find(extra[:comment_id])
      end

      def comment_type
        comment.depth.zero? ? :comment : :reply
      end

      def url_params
        comment_type == :comment ? {} : { anchor: "comment_#{comment.id}" }
      end
    end
  end
end
