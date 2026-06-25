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
          @available_orders ||= possible_orders
        end

        def possible_orders
          @possible_orders ||= begin
            possible_orders = %w(random recent)
            possible_orders << "most_commented" if most_commented_order_available?
            possible_orders
          end
        end

        def default_order
          "recent"
        end

        def most_commented_order_available?
          return @most_commented_order_available if defined?(@most_commented_order_available)

          @most_commented_order_available = Decidim::Blogs::Post.most_commented_available?(current_component)
        end

        def reorder(posts)
          case order
          when "recent"
            posts.order(published_at: :desc)
          when "most_commented"
            posts.order(comments_count: :desc)
          when "random"
            posts.order_randomly(random_seed)
          else
            posts
          end
        end

        def paginate_posts
          @paginate_posts ||= paginate(reorder(posts))
        end
      end
    end
  end
end
