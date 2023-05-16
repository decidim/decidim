# frozen_string_literal: true

module Decidim
  module Blogs
    # This cell renders metadata for an instance of a Post
    class PostMetadataGCell < PostMetadataCell
      private

      def post_items
        [author_item, comments_count_item]
      end
    end
  end
end
