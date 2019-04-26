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

      # Return a percentage of the current order project from total projects
      def current_order_project_percent
        current_order&.project_percent.to_f.floor
      end

      def current_order_percent_minimum
        return 100 if component_settings.vote_per_project

        component_settings.vote_threshold_percent
      end

      def current_order_percent
        return current_order_budget_percent unless component_settings.vote_per_project

        current_order_project_percent
      end

      # Return true if the current order is checked out
      delegate :checked_out?, to: :current_order, prefix: true, allow_nil: true

      # Return true if the current order is pending
      delegate :pending?, to: :current_order, prefix: true, allow_nil: true

      # Return true if the user can continue to the checkout process
      def current_order_can_be_checked_out?
        current_order&.can_checkout?
      end

      # Return true if the order process is pending
      def current_order_is_pending?
        current_order&.pending?
      end

      def budget_summary_state
        return "budget_summary_state--completed" if current_order_can_be_checked_out?
        return "budget_summary_state--pending" if current_order_is_pending?

        ""
      end

      def progress_meter_state
        return "progress_meter_state--completed" if current_order_can_be_checked_out?
        return "progress_meter_state--pending" if current_order_is_pending?

        ""
      end
    end
  end
end
