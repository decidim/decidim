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

      # Return the minimum percentage of the current order budget from the total budget
      def current_order_budget_percent_minimum
        return 0 if current_order.minimum_projects_rule?

        if current_order.projects_rule?
          (current_order.minimum_projects.to_f / current_order.maximum_projects)
        else
          component_settings.vote_threshold_percent
        end
      end

      def budget_confirm_disabled_attr
        return if current_order_can_be_checked_out?

        %( disabled="disabled" ).html_safe
      end

      # Return true if the current order is checked out
      delegate :checked_out?, to: :current_order, prefix: true, allow_nil: true

      # Return true if the user can continue to the checkout process
      def current_order_can_be_checked_out?
        current_order&.can_checkout?
      end

      # Returns false if the current order does not have a rule for minimum budget
      # Returns false if the current order has not reached the minimum budget
      # Otherwhise returns true
      def current_order_minimum_reached?
        return false if current_order.minimum_budget.zero?

        current_order.total > current_order.minimum_budget
      end

      def current_rule_call_for_action_text
        return "" unless current_order

        if current_order_minimum_reached?
          t(".dynamic_help.minimum_reached")
        elsif current_order.projects.empty?
          t(".dynamic_help.start_adding_projects")
        else
          t(".dynamic_help.keep_adding_projects")
        end
      end

      def current_rule_description
        return unless current_order

        rule_text = if current_order_minimum_reached?
                      ""
                    elsif current_order.projects_rule?
                      if current_order.minimum_projects.positive? && current_order.minimum_projects < current_order.maximum_projects
                        t(
                          ".projects_rule.description",
                          minimum_number: current_order.minimum_projects,
                          maximum_number: current_order.maximum_projects
                        )
                      else
                        t(".projects_rule_maximum_only.description", maximum_number: current_order.maximum_projects)
                      end
                    elsif current_order.minimum_projects_rule?
                      t(".minimum_projects_rule.description", minimum_number: current_order.minimum_projects)
                    else
                      t(".vote_threshold_percent_rule.description", minimum_budget: budget_to_currency(current_order.minimum_budget))
                    end

        %(<strong>#{current_rule_call_for_action_text}</strong>. #{rule_text} #{cell("decidim/budgets/budget_information_modal", budget)}).html_safe
      end
    end
  end
end
