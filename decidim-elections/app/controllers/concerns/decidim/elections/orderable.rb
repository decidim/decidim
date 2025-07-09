# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Elections
    # Common logic to sorting resources
    module Orderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        private

        # Available orders based on enabled settings
        def available_orders
          @available_orders ||= [default_order] + possible_orders.excluding(default_order)
        end

        def possible_orders
          @possible_orders ||= begin
            possible_orders = %w(random recent start_at end_at)
            possible_orders << "most_voted"
            possible_orders
          end
        end

        def default_order
          "updated"
        end

        def reorder(elections)
          case order
            # when "most_voted"
            #   elections.order(election_votes_count: :desc)
          when "random"
            elections.order_randomly(random_seed)
          when "recent"
            elections.order(published_at: :desc)
          when "start_at"
            elections.order(start_at: :asc)
          when "end_at"
            elections.order(end_at: :asc)
          else
            elections
          end
        end
      end
    end
  end
end
