# frozen-string_literal: true

module Decidim
  module Comments
    class UserMentionedEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent

      delegate :author, to: :comment

      def i18n_scope
        "decidim.events.comments.user_mentioned"
      end

      def resource_path
        resource_locator.path(url_params)
      end

      def resource_url
        resource_locator.url(url_params)
      end

      private

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
