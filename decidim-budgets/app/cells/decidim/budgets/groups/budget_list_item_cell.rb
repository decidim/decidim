# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      # This cell renders the budget item list for a budget group list
      class BudgetListItemCell < BaseCell
        private

        def order
          return unless current_user

          Decidim::Budgets::Order.find_by(decidim_user_id: current_user.id, decidim_component_id: model.id)
        end

        def card_class
          css = "card--list__item"
          css += " card--list__data-added" if order
          css
        end

        def link_class
          "card__link card--list__heading"
        end
      end
    end
  end
end
