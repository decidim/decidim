# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Debates
    # Common logic to sorting resources
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
            possible_orders = %w(random recent updated)
            possible_orders << "most_commented" if most_commented_order_available?
            possible_orders
          end
        end

        def default_order
          "updated"
        end

        def most_commented_order_available?
          return @most_commented_order_available if defined?(@most_commented_order_available)

          @most_commented_order_available = Decidim::Debates::Debate.most_commented_available?(current_component)
        end

        def reorder(debates)
          case order
          when "recent"
            debates.order(created_at: :desc)
          when "most_commented"
            debates.order(comments_count: :desc)
          when "updated"
            debates.order(updated_at: :desc)
          when "random"
            debates.order_randomly(random_seed)
          else
            debates
          end
        end
      end
    end
  end
end
