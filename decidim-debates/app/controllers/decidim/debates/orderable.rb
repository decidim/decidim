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
          @available_orders ||= %w(random recent commented updated)
        end

        def default_order
          "updated"
        end

        def reorder(debates)
          case order
          when "recent"
            debates.order(created_at: :desc)
          when "commented"
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
