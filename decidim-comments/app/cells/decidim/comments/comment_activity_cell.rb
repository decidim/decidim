# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display when a comment has been created.
    class CommentActivityCell < ActivityCell
      delegate :root_commentable, to: :comment

      def renderable?
        comment.present? && root_commentable.present?
      end

      def resource_link_text
        comment.formatted_body
      end

      def resource_link_path
        resource_locator(root_commentable).path(url_params)
      end

      def title
        I18n.t(
          "decidim.comments.last_activity.new_comment_at_html",
          link: link_to(
            root_commentable_title,
            resource_locator(root_commentable).path
          )
        )
      end

      def participatory_space
        model.participatory_space_lazy
      end

      def comment
        model.resource_lazy
      end

      def root_commentable_title
        decidim_html_escape(translated_attribute(root_commentable.title))
      end

      def url_params
        { anchor: "comment_#{comment.id}" }
      end
    end
  end
end
