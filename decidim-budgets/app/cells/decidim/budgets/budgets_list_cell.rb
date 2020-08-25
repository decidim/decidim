# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the budgets list of a Budget component
    class BudgetsListCell < BaseCell
      alias current_workflow model

      delegate :highlighted, :voted, to: :current_workflow

      def show
        return unless current_workflow.budgets

        render
      end

      private

      def voted?
        current_user && current_workflow.voted.any?
      end

      def finished?
        return unless current_workflow.budgets.any?

        current_user && (current_workflow.allowed - current_workflow.voted).none?
      end

      def i18n_scope
        "decidim.budgets.budgets_list"
      end
    end
  end
end
