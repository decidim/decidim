# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Blogs
    module Orderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        private

        def available_orders
          %w(recent most_commented)
        end

        def default_order
          "recent"
        end

        def paginate_posts
          @paginate_posts ||= paginate(reorder(posts))
        end

        def reorder(posts)
          case order
          when "most_commented"
            posts.order(comments_count: :desc)
          else
            posts.published_at_desc
          end
        end
      end
    end
  end
end
