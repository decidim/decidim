# frozen_string_literal: true

module Decidim
  module Comments
    # A helper to expose the comments component for a commentable
    module CommentsHelper
      # Render commentable comments inside the `expanded` template content.
      #
      # resource - A commentable resource
      def comments_for(resource)
        return unless resource.commentable?

        content_for :expanded do
          inline_comments_for(resource)
        end
      end

      # Creates a Comments component through the comments cell.
      #
      # resource - A commentable resource
      #
      # Returns the comments cell
      def inline_comments_for(resource, options = {})
        return unless resource.commentable?

        cell(
          "decidim/comments/comments",
          resource,
          machine_translations: machine_translations_toggled?,
          single_comment: params.fetch("commentId", nil),
          order: options[:order]
        ).to_s
      end
    end
  end
end
