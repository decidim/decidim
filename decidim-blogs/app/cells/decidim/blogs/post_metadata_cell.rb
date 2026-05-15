# frozen_string_literal: true

module Decidim
  module Blogs
    # This cell renders metadata for an instance of a Proposal
    class PostMetadataCell < Decidim::CardMetadataCell
      def initialize(*)
        super

        @items.prepend(*post_items)
      end

      private

      def post_items
        [author_item, creation_date, comments_count_item, likes_count_item]
      end

      def creation_date
        date_at = model.try(:published_at) || model.try(:created_at)

        {
          text: l(date_at.to_date, format: :decidim_short_with_month_name_short),
          icon: "calendar-todo-line"
        }
      end
    end
  end
end
