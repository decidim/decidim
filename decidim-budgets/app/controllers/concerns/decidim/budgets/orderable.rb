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
            available_orders << "random" if voting_is_open? || !votes_are_visible?
            available_orders << "most_voted" if votes_are_visible?
            available_orders += %w(highest_cost lowest_cost)
            available_orders
          end
        end

        def default_order
          available_orders.first
        end

        def voting_is_open?
          current_settings.votes_enabled?
        end

        def votes_are_visible?
          current_settings.show_votes?
        end

        def reorder(projects)
          case order
          when "highest_cost"
            projects.order(budget_amount: :desc)
          when "lowest_cost"
            projects.order(budget_amount: :asc)
          when "most_voted"
            if votes_are_visible?
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
