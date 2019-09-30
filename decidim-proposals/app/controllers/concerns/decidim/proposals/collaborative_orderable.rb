# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Proposals
    # Common logic to ordering resources
    module CollaborativeOrderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        private

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
