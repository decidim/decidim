# frozen_string_literal: true

module Decidim
  module Blogs
    # This cell renders the Grid (:g) post card
    # for an given instance of a Post
    class PostGCell < Decidim::CardMCell
      private

      def photo
        @photo ||= model.photo
      end

      def has_image?
        photo.present?
      end

      def resource_image_path
        photo.url if has_image?
      end
    end
  end
end
