# frozen_string_literal: true
module Decidim
  module Budgets
    # A helper to render order and budgets actions
    module ProjectsHelper
      # Render a budget as a currency
      #
      # budget - A integer to represent a budget
      def budget_to_currency(budget)
        number_to_currency budget, unit: "€", delimiter: ".", precision: 0, format: "%n %u"
      end

      # Return a percentage of the current order budget from the total budget
      def current_order_total_budget_percent
        return 0 unless current_order
        ((current_order.total_budget.to_f / feature_settings.total_budget.to_f) * 100).floor
      end

      # Return true if the current order is checked out
      def current_order_checked_out?
        current_order && current_order.checked_out?
      end

      # Return true if the user can continue to the checkout process
      def user_can_checkout?
        return false unless current_order
        current_order.total_budget.to_f >= (feature_settings.total_budget.to_f * (feature_settings.vote_threshold_percent.to_f / 100))
      end
    end
  end
end
