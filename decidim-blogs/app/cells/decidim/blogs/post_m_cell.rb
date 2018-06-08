# frozen_string_literal: true

module Decidim
  module Blogs
    # This cell renders the Medium (:m) post card
    # for an given instance of a Post
    class PostMCell < Decidim::CardMCell
      private

      def has_actions?
        false
      end
    end
  end
end
