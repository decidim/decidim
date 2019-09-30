# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Consultations
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

        def reorder(consultations)
          case order
          when "recent"
            consultations.order_by_most_recent
          else
            consultations.order_randomly(random_seed)
          end
        end
      end
    end
  end
end
