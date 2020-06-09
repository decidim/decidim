# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Initiatives
    # Common logic to ordering resources
    module Orderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        # Available orders based on enabled settings
        def available_orders
          @available_orders ||= begin
            available_orders = %w(random recent most_voted most_commented recently_published)
            available_orders
          end
        end

        def default_order
          "random"
        end

        def reorder(initiatives)
          case order
          when "most_voted"
            initiatives.order_by_supports
          when "most_commented"
            initiatives.order_by_most_commented
          when "recent"
            initiatives.order_by_most_recent
          when "recently_published"
            initiatives.order_by_most_recently_published
          else
            initiatives.order_randomly(random_seed)
          end
        end
      end
    end
  end
end
