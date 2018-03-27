# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Proposals
    # Common logic to ordering resources
    module CollaborativeOrderable
      extend ActiveSupport::Concern

      included do
        helper_method :order, :available_orders, :random_seed

        private

        # Gets how the proposals should be ordered based on the choice made by the user.
        def order
          @order ||= detect_order(params[:order]) || default_order
        end

        # Available orders based on enabled settings
        def available_orders
          @available_orders ||= begin
            available_orders = %w(random recent)
            available_orders << "most_contributed"
            available_orders
          end
        end

        def default_order
          detect_order("most_contributed")
        end

        # Returns: A random float number between -1 and 1 to be used as a random seed at the database.
        def random_seed
          @random_seed ||= (params[:random_seed] ? params[:random_seed].to_f : (rand * 2 - 1))
        end

        def detect_order(candidate)
          available_orders.detect { |order| order == candidate }
        end

        def reorder(drafts)
          case order
          when "random"
            drafts.order_randomly(random_seed)
          when "most_contributed"
            drafts.order(contributions_count: :desc)
          when "recent"
            drafts.order(created_at: :desc)
          end
        end
      end
    end
  end
end
