# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display when a comment has been created.
    class CommentActivityCell < ActivityCell
      delegate :commentable, to: :comment

      def renderable?
        comment.present? && commentable.present?
      end

      def resource_link_text
        comment.body
      end

      def resource_link_path
        resource_locator(commentable).path(url_params)
      end

      def title
        I18n.t(
          "decidim.comments.last_activity.new_comment_at_html",
          link: link_to(
            translated_attribute(commentable.title),
            resource_locator(commentable).path
          )
        )
      end

      def participatory_space
        model.participatory_space_lazy
      end

      def comment
        model.resource_lazy
      end

      def url_params
        { anchor: "comment_#{comment.id}" }
      end
    end
  end
end
