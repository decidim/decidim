# frozen_string_literal: true

module Decidim
  module Blogs
    # This cell renders the Grid (:g) post card
    # for a given instance of a Post
    class PostGCell < Decidim::CardGCell
      delegate :photo, to: :model

      private

      def has_image?
        resource_image_path.present?
      end

      def show_description?
        true
      end

      def metadata_cell
        "decidim/blogs/post_metadata_g"
      end

      def resource_image_path
        return if photo.blank?

        photo.url
      end
    end
  end
end
