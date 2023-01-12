# frozen_string_literal: true

module Decidim
  module Blogs
    # This cell renders the Grid (:g) post card
    # for an given instance of a Post
    class PostGCell < Decidim::CardGCell
      private

      def photo
        @photo ||= model.photo
      end

      def resource_image_path
        return if photo.blank?

        photo.url
      end
    end
  end
end
