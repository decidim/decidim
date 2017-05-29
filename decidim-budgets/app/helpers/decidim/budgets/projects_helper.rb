# frozen_string_literal: true

module Decidim
  module Budgets
    # A helper to render order and budgets actions
    module ProjectsHelper
      # Render a budget as a currency
      #
      # budget - A integer to represent a budget
      def budget_to_currency(budget)
        number_to_currency budget, unit: Decidim.currency_unit, precision: 0
      end

      # Return a percentage of the current order budget from the total budget
      def current_order_budget_percent
        current_order&.budget_percent.to_f.floor
      end

      # Return true if the current order is checked out
      def current_order_checked_out?
        current_order&.checked_out?
      end

      # Return true if the user can continue to the checkout process
      def current_order_can_be_checked_out?
        current_order&.can_checkout?
      end
    end
  end
end
