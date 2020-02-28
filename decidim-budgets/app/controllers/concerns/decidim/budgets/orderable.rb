# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Budgets
    # Common logic to sorting resources
    module Orderable
      extend ActiveSupport::Concern

      included do
        include Decidim::Orderable

        private

        # Available orders based on enabled settings
        def available_orders
          @available_orders ||= begin
            available_orders = []

            available_orders << if most_voted_order_available?
                                  "most_voted"
                                else
                                  "random"
                                end

            available_orders += %w(highest_cost lowest_cost)
            available_orders
          end
        end

        def default_order
          if most_voted_order_available?
            detect_order("most_voted")
          else
            "random"
          end
        end

        def most_voted_order_available?
          !current_settings.votes_enabled? && current_settings.show_votes?
        end

        def reorder(projects)
          case order
          when "highest_cost"
            projects.order(budget: :desc)
          when "lowest_cost"
            projects.order(budget: :asc)
          when "most_voted"
            if most_voted_order_available?
              ids = projects.sort_by(&:confirmed_orders_count).map(&:id).reverse
              projects.ordered_ids(ids)
            else
              projects
            end
          when "random"
            projects.order_randomly(random_seed)
          else
            projects
          end
        end
      end
    end
  end
end
