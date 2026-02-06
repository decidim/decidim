# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the budgets list of a Budget component
    class BudgetsListCell < BaseCell
      AVAILABLE_ORDERS = %w(random highest_cost lowest_cost).freeze

      include Decidim::CellsPaginateHelper
      include Decidim::OrdersHelper
      include Decidim::Orderable
      include Cell::ViewModel::Partial

      alias current_workflow model

      delegate :allowed, :budgets, :highlighted, :voted, to: :current_workflow
      delegate :voting_open?, :voting_finished?, to: :controller

      def show
        return unless budgets

        render
      end

      def main_list = render

      private

      def progress?
        current_user && voting_open? && progress_budgets.any?
      end

      def progress_budgets
        budgets.select { |budget| current_workflow.status(budget) == :progress }
      end

      def non_voted_budgets
        budgets.where.not(id: voted.map(&:id))
      end

      def highlighted?
        current_user && highlighted.any?
      end

      def voted?
        current_user && voted.any?
      end

      def non_highlighted
        budgets_to_exclude = if voting_finished?
                               highlighted + voted
                             else
                               highlighted + voted + progress_budgets
                             end

        reorder(budgets).where.not(id: budgets_to_exclude.map(&:id))
      end

      def finished?
        return unless budgets.any?

        current_user && (allowed - voted).none?
      end

      def i18n_scope
        "decidim.budgets.budgets_list"
      end

      def budget_paginate
        @budget_paginate ||= Kaminari.paginate_array(budgets).page(params[:page]).per(10)
      end

      def reordered_highlighted_budgets
        return highlighted if highlighted.length < 2

        reorder(budgets.where(id: highlighted.map(&:id)))
      end

      def reorder(budgets)
        case order
        when "highest_cost"
          budgets.order(total_budget: :desc)
        when "lowest_cost"
          budgets.order(total_budget: :asc)
        when "random"
          budgets.order_randomly(random_seed)
        else
          budgets
        end
      end

      def available_orders = AVAILABLE_ORDERS
    end
  end
end
