# frozen_string_literal: true

module Decidim
  module Blogs
    # This cell renders the Search (:s) post card
    # for a given instance of a Post
    class PostSCell < Decidim::CardSCell
      private

      def metadata_cell
        "decidim/blogs/post_metadata"
      end
    end
  end
end
