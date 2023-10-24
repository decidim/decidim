# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the Search (:s) budget card
    # for a given instance of a Budget
    class BudgetSCell < Decidim::CardSCell
      private

      def metadata_cell
        "decidim/budgets/budget_metadata"
      end
    end
  end
end
