# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the budgets list of a Budget component
    class BudgetsListCell < BaseCell
      alias current_workflow model

      delegate :allowed, :budgets, :highlighted, :voted, to: :current_workflow
      delegate :voting_open?, to: :controller

      def show
        return unless budgets

        render
      end

      private

      def highlighted?
        current_user && highlighted.any?
      end

      def voted?
        current_user && voted.any?
      end

      def finished?
        return unless budgets.any?

        current_user && (allowed - voted).none?
      end

      def i18n_scope
        "decidim.budgets.budgets_list"
      end
    end
  end
end
