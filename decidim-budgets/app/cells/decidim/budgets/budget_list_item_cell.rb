# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders the budget item list in the budgets list
    class BudgetListItemCell < BaseCell
      property :title
      alias budget model

      private

      def card_class
        css = "card--list__item"
        css += " card--list__data-added" if voted?
        css += " card--list__data-progress" if progress?
        css
      end

      def link_class
        "card__link card--list__heading"
      end

      def voted?
        current_user && status == :voted
      end

      def progress?
        current_user && status == :progress
      end

      def status
        @status ||= current_workflow.status(model)
      end
    end
  end
end
