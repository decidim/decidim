# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      # This cell renders the budget item list for a budget group list
      class BudgetListItemCell < BaseCell
        def group_component
          component.parent
        end

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
          @status ||= workflow_instance.status(component)
        end
      end
    end
  end
end
