# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the budget card for an instance of a budget
    # the default size is the Medium Card (:m)
    class BudgetCell < Decidim::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, model, options
      end

      private

      def card_size
        "decidim/budgets/budget_m"
      end
    end
  end
end
