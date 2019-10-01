# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Sortitions
    # Common logic to ordering resources
    module Orderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        private

        # Available orders based on enabled settings
        def available_orders
          %w(random recent)
        end

        def default_order
          "recent"
        end

        def reorder(sortitions)
          case order
          when "random"
            sortitions.order_randomly(random_seed)
          when "recent"
            sortitions.order(created_at: :desc)
          end
        end
      end
    end
  end
end
