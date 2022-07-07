# frozen_string_literal: true

module Decidim
  module Comments
    # Custom helpers for comments cells.
    #
    module CommentCellsHelper
      def renderable?
        comment.present? && root_commentable.present?
      end

      def resource_link_text
        comment.formatted_body
      end

      def resource_link_path
        return root_commentable.polymorphic_resource_path(url_params) if root_commentable.respond_to?(:polymorphic_resource_path)

        resource_locator(root_commentable).path(url_params)
      end

      delegate :root_commentable, to: :comment

      def root_commentable_title
        decidim_html_escape(translated_attribute(root_commentable.title))
      end

      def url_params
        { commentId: comment.id }
      end
    end
  end
end
