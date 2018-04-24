# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Initiatives
    # Common logic to ordering resources
    module Orderable
      extend ActiveSupport::Concern

      included do
        helper_method :order, :available_orders, :random_seed

        private

        # Gets how the proposals should be ordered based on the choice
        # made by the user.
        def order
          @order ||= detect_order(params[:order]) || default_order
        end

        def detect_order(candidate)
          available_orders.detect { |order| order == candidate }
        end

        # Available orders based on enabled settings
        def available_orders
          @available_orders ||= begin
            available_orders = %w(random recent most_voted most_commented)
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
          else
            initiatives.order_randomly(random_seed)
          end
        end

        # Returns: A random float number between -1 and 1 to be used as a
        # random seed at the database.
        def random_seed
          @random_seed ||= (params[:random_seed] ? params[:random_seed].to_f : (rand * 2 - 1))
        end
      end
    end
  end
end
