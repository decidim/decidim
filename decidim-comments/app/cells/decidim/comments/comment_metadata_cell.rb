# frozen_string_literal: true

module Decidim
  module Comments
    # This cell renders the comment metadata for a card
    class CommentMetadataCell < Decidim::CardMetadataCell
      delegate :root_commentable, to: :model

      private

      def items
        [author_item, commentable_item, (comments_count_item || {})]
      end

      def commentable_item
        {
          text: decidim_escape_translated(root_commentable.title),
          icon: resource_type_icon_key(root_commentable.class)
        }
      end

      def comments_count_item
        super(root_commentable)
      end
    end
  end
end
