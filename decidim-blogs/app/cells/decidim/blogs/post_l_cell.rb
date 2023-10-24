# frozen_string_literal: true

module Decidim
  module Blogs
    # This cell renders the List (:l) post card
    # for a given instance of a Post
    class PostLCell < Decidim::CardLCell
      delegate :photo, to: :model

      private

      def has_image?
        true
      end

      def has_description?
        true
      end

      def description_length
        500
      end

      def metadata_cell
        "decidim/blogs/post_metadata"
      end

      def resource_image_path
        return if photo.blank?

        photo.url
      end
    end
  end
end
