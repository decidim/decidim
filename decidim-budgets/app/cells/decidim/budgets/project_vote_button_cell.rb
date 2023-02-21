# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders an authorized_action button
    # to vote a given instance of a Project in a budget list
    class ProjectVoteButtonCell < ProjectListItemCell
      def modal_params
        return {} if resource_added? || below_maximum?

        { dialog_open: "budget-excess" }
      end

      def remaining_amount
        model.budget.total_budget - (current_order&.total_budget || 0)
      end

      def below_maximum?
        model.budget_amount <= remaining_amount
      end
    end
  end
end
