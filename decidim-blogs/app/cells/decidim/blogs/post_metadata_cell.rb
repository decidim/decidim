# frozen_string_literal: true

module Decidim
  module Blogs
    # This cell renders metadata for an instance of a Proposal
    class PostMetadataCell < Decidim::CardMetadataCell
      delegate :state, to: :model

      def initialize(*)
        super

        @items.prepend(*post_items)
      end

      private

      def post_items
        [author_item, comments_count_item, endorsements_count_item]
      end
    end
  end
end
