# frozen-string_literal: true

module Decidim
  module Comments
    class CommentCreatedEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_subject
        I18n.t(
          "decidim.comments.events.comment_created.#{comment_type}.email_subject",
          resource_title: resource_title,
          resource_url: resource_locator.url(url_params),
          author_name: comment.author.name
        )
      end

      def email_intro
        I18n.t(
          "decidim.comments.events.comment_created.#{comment_type}.email_intro",
          resource_title: resource_title
        ).html_safe
      end

      def email_outro
        I18n.t(
          "decidim.comments.events.comment_created.#{comment_type}.email_outro",
          resource_title: resource_title
        )
      end

      def notification_title
        I18n.t(
          "decidim.comments.events.comment_created.#{comment_type}.notification_title",
          resource_title: resource_title,
          resource_path: resource_locator.path(url_params),
          author_name: comment.author.name
        ).html_safe
      end

      private

      def comment
        @comment ||= Decidim::Comments::Comment.find(extra["comment_id"])
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
