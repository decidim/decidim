# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the project budget amount
    class ProjectBudgetAmountCell < Decidim::ViewModel
      delegate :voting_finished?, to: :controller

      def show
        budget_to_currency(model.budget_amount)
      end
    end
  end
end
